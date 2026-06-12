use crate::auth::{check_password, generate_token, Claims};
use crate::error::{AppError, Result};
use crate::models::*;
use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::Json,
};
use bcrypt::{hash, DEFAULT_COST};
use rand::Rng;
use serde_json::json;
use sqlx::{MySqlPool, Row};

fn cents_to_yuan(cents: i64) -> f64 {
    cents as f64 / 100.0
}

// ---------- 注册 ----------
pub async fn register(
    State(pool): State<MySqlPool>,
    Json(req): Json<RegisterRequest>,
) -> Result<Json<serde_json::Value>> {
    if !req.phone.starts_with('1') || req.phone.len() != 11 {
        return Err(AppError::BadRequest("手机号无效".into()));
    }
    if req.password.len() < 8 {
        return Err(AppError::BadRequest("密码至少8位".into()));
    }
    let real_name = req
        .realName
        .unwrap_or_else(|| format!("用户{}", &req.phone[7..]));

    let existing: Option<(i32,)> = sqlx::query_as("SELECT userId FROM users WHERE phone = ?")
        .bind(&req.phone)
        .fetch_optional(&pool)
        .await?;
    if existing.is_some() {
        return Err(AppError::DuplicateEntry);
    }

    let account = format!("u{}", &req.phone[3..]);
    let password_hash = hash(&req.password, DEFAULT_COST).map_err(|_| AppError::Internal)?;

    sqlx::query(
        "INSERT INTO users (account, password, realName, userType, phone, state) VALUES (?, ?, ?, 1, ?, 1)",
    )
    .bind(&account)
    .bind(&password_hash)
    .bind(&real_name)
    .bind(&req.phone)
    .execute(&pool)
    .await?;

    let row = sqlx::query(
        "SELECT userId, phone, realName, userType FROM users WHERE phone = ?",
    )
    .bind(&req.phone)
    .fetch_one(&pool)
    .await?;
    let user_id: i32 = row.get(0);
    let phone: Option<String> = row.get(1);
    let real_name: String = row.get(2);
    let user_type: i32 = row.get(3);
    let phone = phone.ok_or(AppError::Internal)?;
    let token = generate_token(user_id, &phone, 1)?;

    Ok(Json(json!({
        "token": token,
        "user": {
            "userId": user_id,
            "phone": phone,
            "realName": real_name,
            "userType": user_type,
        }
    })))
}

// ---------- 登录 ----------
pub async fn login(
    State(pool): State<MySqlPool>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<serde_json::Value>> {
    let row = sqlx::query(
        "SELECT userId, phone, realName, userType, password, state FROM users WHERE phone = ?",
    )
    .bind(&req.phone)
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    let user_id: i32 = row.get(0);
    let phone: Option<String> = row.get(1);
    let real_name: String = row.get(2);
    let user_type: i32 = row.get(3);
    let stored_hash: Option<String> = row.get(4);
    let state: i32 = row.get(5);

    if state != 1 {
        return Err(AppError::Unauthorized);
    }

    let stored_hash = stored_hash.ok_or(AppError::Internal)?;
    if !check_password(&req.password, &stored_hash)? {
        return Err(AppError::Unauthorized);
    }

    let phone = phone.ok_or(AppError::Internal)?;
    let token = generate_token(user_id, &phone, user_type)?;

    Ok(Json(json!({
        "token": token,
        "user": {
            "userId": user_id,
            "phone": phone,
            "realName": real_name,
            "userType": user_type,
        }
    })))
}

// ---------- 重置密码 ----------
pub async fn reset_password(
    State(pool): State<MySqlPool>,
    Json(req): Json<ResetPasswordRequest>,
) -> Result<Json<serde_json::Value>> {
    if req.code != "123456" {
        return Err(AppError::BadRequest("验证码错误".into()));
    }

    let row: Option<(i32,)> = sqlx::query_as(
        "SELECT userId FROM users WHERE phone = ? AND state = 1",
    )
    .bind(&req.phone)
    .fetch_optional(&pool)
    .await?;
    let (user_id,) = row.ok_or(AppError::Unauthorized)?;

    let new_hash = hash(&req.new_password, DEFAULT_COST).map_err(|_| AppError::Internal)?;
    sqlx::query("UPDATE users SET password = ? WHERE userId = ?")
        .bind(&new_hash)
        .bind(user_id)
        .execute(&pool)
        .await?;

    Ok(Json(json!({ "message": "密码重置成功" })))
}

// ---------- 商品列表 ----------
pub async fn list_products(
    State(pool): State<MySqlPool>,
    Query(params): Query<ProductQuery>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let on_shelf = params.on_shelf.unwrap_or(true);
    let mut sql = String::from(
        "SELECT prodId, name, category, price, stock, picture, description, state FROM product WHERE 1=1",
    );
    let mut binds = vec![];
    if let Some(cat) = params.category {
        sql.push_str(" AND category = ?");
        binds.push(cat.to_string());
    }
    sql.push_str(" AND state = ?");
    binds.push(if on_shelf { "1" } else { "0" }.to_string());
    sql.push_str(" ORDER BY prodId");

    let mut query = sqlx::query(&sql);
    for b in binds {
        query = query.bind(b);
    }
    let rows = query.fetch_all(&pool).await?;
    let mut products = Vec::new();
    for row in rows {
        products.push(json!({
            "prodId": row.get::<i32, _>(0),
            "name": row.get::<String, _>(1),
            "category": row.get::<i32, _>(2),
            "price": cents_to_yuan(row.get::<i64, _>(3)),
            "stock": row.get::<i32, _>(4),
            "picture": row.get::<Option<String>, _>(5),
            "description": row.get::<Option<String>, _>(6),
            "state": row.get::<i32, _>(7),
        }));
    }
    Ok(Json(products))
}

// ---------- 创建订单 ----------
pub async fn create_order(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<CreateOrderRequest>,
) -> Result<Json<serde_json::Value>> {
    let user_id = claims.sub;
    if req.items.is_empty() {
        return Err(AppError::BadRequest("订单商品不能为空".into()));
    }
    if req.deliveryType != 1 && req.deliveryType != 2 {
        return Err(AppError::BadRequest("配送方式无效".into()));
    }
    if req.deliveryType == 1 && req.revId.is_none() {
        return Err(AppError::BadRequest("配送至座位必须指定预约ID".into()));
    }

    let mut tx = pool.begin().await?;
    let mut total_cents = 0i64;
    let mut items_info = Vec::new();

    for item in &req.items {
        let prod = sqlx::query(
            "SELECT prodId, price, stock, state FROM product WHERE prodId = ? FOR UPDATE",
        )
        .bind(item.prodId)
        .fetch_optional(&mut *tx)
        .await?
        .ok_or(AppError::NotFound)?;
        let prod_id: i32 = prod.get(0);
        let price: i64 = prod.get(1);
        let stock: i32 = prod.get(2);
        let state: i32 = prod.get(3);
        if state != 1 {
            return Err(AppError::BadRequest("商品已下架".into()));
        }
        if stock < item.quantity {
            return Err(AppError::InsufficientStock);
        }
        total_cents += price * item.quantity as i64;
        items_info.push((prod_id, item.quantity, price));
    }

    for (prod_id, qty, _) in &items_info {
        sqlx::query("UPDATE product SET stock = stock - ? WHERE prodId = ?")
            .bind(qty)
            .bind(prod_id)
            .execute(&mut *tx)
            .await?;
    }

    let now = chrono::Local::now().naive_local();
    let random_suffix: u32 = rand::thread_rng().gen_range(0..10000);
    let order_no = format!("F{}{:03}{:04}", now.format("%Y%m%d%H%M%S"), user_id, random_suffix);

    let insert = sqlx::query(
        "INSERT INTO foodorder (orderNo, userId, revId, totalAmount, deliveryType, status, createTime)
         VALUES (?, ?, ?, ?, ?, 1, ?)",
    )
    .bind(&order_no)
    .bind(user_id)
    .bind(req.revId)
    .bind(total_cents)
    .bind(req.deliveryType)
    .bind(now)
    .execute(&mut *tx)
    .await?;
    let order_id = insert.last_insert_id();

    for (prod_id, qty, price_cents) in items_info {
        sqlx::query(
            "INSERT INTO orderdetail (orderId, prodId, quantity, price) VALUES (?, ?, ?, ?)",
        )
        .bind(order_id)
        .bind(prod_id)
        .bind(qty)
        .bind(price_cents)
        .execute(&mut *tx)
        .await?;
    }

    tx.commit().await?;

    Ok(Json(json!({
        "orderId": order_id,
        "orderNo": order_no,
        "totalAmount": cents_to_yuan(total_cents),
    })))
}

// ---------- 用户订单列表 ----------
pub async fn list_orders(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let user_id = claims.sub;
    let rows = sqlx::query(
        "SELECT orderId, orderNo, totalAmount, deliveryType, status, createTime, payTime, cancelTime
         FROM foodorder WHERE userId = ? ORDER BY createTime DESC",
    )
    .bind(user_id)
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for o in rows {
        let order_id: i32 = o.get(0);
        let order_no: String = o.get(1);
        let total_amount: Option<i64> = o.get(2);
        let delivery_type: i32 = o.get(3);
        let status: i32 = o.get(4);
        let create_time: chrono::NaiveDateTime = o.get(5);

        let items = sqlx::query(
            "SELECT od.prodId, od.quantity, od.price, p.name, p.picture
             FROM orderdetail od
             JOIN product p ON od.prodId = p.prodId
             WHERE od.orderId = ?",
        )
        .bind(order_id)
        .fetch_all(&pool)
        .await?;
        let items_json = items
            .into_iter()
            .map(|i| {
                json!({
                    "product": {
                        "id": i.get::<i32, _>(0).to_string(),
                        "name": i.get::<String, _>(3),
                        "price": cents_to_yuan(i.get::<Option<i64>, _>(2).unwrap_or(0)),
                    },
                    "qty": i.get::<i32, _>(1),
                })
            })
            .collect::<Vec<_>>();
        result.push(json!({
            "id": order_id.to_string(),
            "orderNo": order_no,
            "createdAt": create_time,
            "items": items_json,
            "total": cents_to_yuan(total_amount.unwrap_or(0)),
            "delivery": if delivery_type == 1 { "配送至座位" } else { "吧台自取" },
            "status": match status {
                1 => "待支付",
                2 => "已支付",
                3 => "制作中",
                4 => "已完成",
                5 => "已取消",
                _ => "待支付",
            },
            "deliveryStatus": "none",
        }));
    }
    Ok(Json(result))
}

// ---------- 支付订单 ----------
pub async fn pay_order(
    Path(order_id): Path<i32>,
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let mut tx = pool.begin().await?;
    let order = sqlx::query(
        "SELECT userId, status FROM foodorder WHERE orderId = ? FOR UPDATE",
    )
    .bind(order_id)
    .fetch_optional(&mut *tx)
    .await?
    .ok_or(AppError::NotFound)?;
    let order_user_id: i32 = order.get(0);
    let status: i32 = order.get(1);
    if order_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query("UPDATE foodorder SET status = 2, payTime = ? WHERE orderId = ?")
        .bind(chrono::Local::now().naive_local())
        .bind(order_id)
        .execute(&mut *tx)
        .await?;
    tx.commit().await?;
    Ok(StatusCode::OK)
}

// ---------- 取消订单 ----------
pub async fn cancel_order(
    Path(order_id): Path<i32>,
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let mut tx = pool.begin().await?;
    let order = sqlx::query(
        "SELECT userId, status FROM foodorder WHERE orderId = ? FOR UPDATE",
    )
    .bind(order_id)
    .fetch_optional(&mut *tx)
    .await?
    .ok_or(AppError::NotFound)?;
    let order_user_id: i32 = order.get(0);
    let status: i32 = order.get(1);
    if order_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    let items = sqlx::query("SELECT prodId, quantity FROM orderdetail WHERE orderId = ?")
        .bind(order_id)
        .fetch_all(&mut *tx)
        .await?;
    for item in items {
        sqlx::query("UPDATE product SET stock = stock + ? WHERE prodId = ?")
            .bind(item.get::<i32, _>(1))
            .bind(item.get::<i32, _>(0))
            .execute(&mut *tx)
            .await?;
    }
    sqlx::query("UPDATE foodorder SET status = 5, cancelTime = ? WHERE orderId = ?")
        .bind(chrono::Local::now().naive_local())
        .bind(order_id)
        .execute(&mut *tx)
        .await?;
    tx.commit().await?;
    Ok(StatusCode::OK)
}

fn normalize_seat_code(code: &str) -> String {
    code.replace('-', "")
}

fn parse_slot_hours(slots: &[String]) -> Result<(u32, u32)> {
    if slots.is_empty() {
        return Err(AppError::BadRequest("请选择预约时段".into()));
    }
    let mut min_start = 24u32;
    let mut max_end = 0u32;
    for slot in slots {
        let parts: Vec<&str> = slot.split('-').collect();
        if parts.len() != 2 {
            return Err(AppError::BadRequest("时段格式无效".into()));
        }
        let start_hour: u32 = parts[0]
            .split(':')
            .next()
            .and_then(|h| h.parse().ok())
            .ok_or_else(|| AppError::BadRequest("时段格式无效".into()))?;
        let end_hour: u32 = parts[1]
            .split(':')
            .next()
            .and_then(|h| h.parse().ok())
            .ok_or_else(|| AppError::BadRequest("时段格式无效".into()))?;
        if start_hour >= end_hour {
            return Err(AppError::BadRequest("时段格式无效".into()));
        }
        min_start = min_start.min(start_hour);
        max_end = max_end.max(end_hour);
    }
    Ok((min_start, max_end))
}

fn reservation_status_str(status: i32) -> &'static str {
    match status {
        0 => "待支付",
        1 => "预约成功",
        2 => "进行中",
        3 => "已取消",
        4 => "违约",
        5 => "已完成",
        _ => "待支付",
    }
}

// ---------- 创建预约 ----------
pub async fn create_reservation(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<CreateReservationRequest>,
) -> Result<Json<serde_json::Value>> {
    let user_id = claims.sub;
    if req.slots.is_empty() {
        return Err(AppError::BadRequest("请选择预约时段".into()));
    }
    let seat_code = normalize_seat_code(&req.seatCode);
    let res = sqlx::query("SELECT resId, state FROM resource WHERE name = ?")
        .bind(&seat_code)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let res_id: i32 = res.get(0);
    let state: i32 = res.get(1);
    if state != 1 {
        return Err(AppError::BadRequest("座位不可用".into()));
    }

    let (start_hour, end_hour) = parse_slot_hours(&req.slots)?;
    let date = chrono::NaiveDate::parse_from_str(&req.date, "%Y-%m-%d")
        .map_err(|_| AppError::BadRequest("日期格式无效".into()))?;
    let start_time = date
        .and_hms_opt(start_hour, 0, 0)
        .ok_or_else(|| AppError::BadRequest("开始时间无效".into()))?;
    let end_time = date
        .and_hms_opt(end_hour, 0, 0)
        .ok_or_else(|| AppError::BadRequest("结束时间无效".into()))?;

    let conflict = sqlx::query(
        "SELECT revId FROM reservation WHERE resId = ? AND status IN (0, 1, 2)
         AND startTime < ? AND endTime > ? LIMIT 1",
    )
    .bind(res_id)
    .bind(end_time)
    .bind(start_time)
    .fetch_optional(&pool)
    .await?;
    if conflict.is_some() {
        return Err(AppError::BadRequest("所选时段已被预约".into()));
    }

    let now = chrono::Local::now().naive_local();
    let amount_cents = yuan_to_cents(req.fee);
    let insert = sqlx::query(
        "INSERT INTO reservation (userId, resId, startTime, endTime, status, createTime, amount)
         VALUES (?, ?, ?, ?, 0, ?, ?)",
    )
    .bind(user_id)
    .bind(res_id)
    .bind(start_time)
    .bind(end_time)
    .bind(now)
    .bind(amount_cents)
    .execute(&pool)
    .await?;
    let rev_id = insert.last_insert_id() as i32;

    let slots_json: Vec<String> = req.slots.clone();
    Ok(Json(json!({
        "id": rev_id.to_string(),
        "seatCode": req.seatCode,
        "date": req.date,
        "slots": slots_json,
        "status": "待支付",
        "fee": req.fee,
        "verifyCode": format!("{:X}", (rev_id as u64) % 0xFFFFFFFF),
    })))
}

fn yuan_to_cents(yuan: f64) -> i64 {
    (yuan * 100.0).round() as i64
}

// ---------- 支付预约 ----------
pub async fn pay_reservation(
    Path(rev_id): Path<i32>,
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let rev = sqlx::query("SELECT userId, status FROM reservation WHERE revId = ?")
        .bind(rev_id)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let rev_user_id: i32 = rev.get(0);
    let status: i32 = rev.get(1);
    if rev_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 0 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query("UPDATE reservation SET status = 1 WHERE revId = ?")
        .bind(rev_id)
        .execute(&pool)
        .await?;
    Ok(StatusCode::OK)
}

// ---------- 用户公告 ----------
pub async fn list_public_notices(State(pool): State<MySqlPool>) -> Result<Json<Vec<serde_json::Value>>> {
    let rows = sqlx::query(
        "SELECT nId, title, content, createTime FROM notice WHERE state = 1 ORDER BY createTime DESC",
    )
    .fetch_all(&pool)
    .await?;
    let result = rows
        .into_iter()
        .map(|row| {
            let n_id: i32 = row.get(0);
            let title: String = row.get(1);
            let content: String = row.get(2);
            let create_time: chrono::NaiveDateTime = row.get(3);
            let time_str = create_time.format("%Y-%m-%d %H:%M:%S").to_string();
            json!({
                "id": n_id.to_string(),
                "title": title,
                "content": content,
                "publishedAt": time_str,
                "updatedAt": time_str,
            })
        })
        .collect();
    Ok(Json(result))
}

// ---------- 打卡 ----------
pub async fn checkin(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<CheckinRequest>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let rev = sqlx::query("SELECT userId, status FROM reservation WHERE revId = ?")
        .bind(req.revId)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let rev_user_id: i32 = rev.get(0);
    let status: i32 = rev.get(1);
    if rev_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query("UPDATE reservation SET status = 2, checkinTime = ? WHERE revId = ?")
        .bind(chrono::Local::now().naive_local())
        .bind(req.revId)
        .execute(&pool)
        .await?;
    let order: Option<(i32,)> = sqlx::query_as(
        "SELECT orderId FROM foodorder WHERE userId = ? AND revId = ? AND deliveryType = 1 AND status = 2",
    )
    .bind(user_id)
    .bind(req.revId)
    .fetch_optional(&pool)
    .await?;
    if let Some((oid,)) = order {
        sqlx::query("UPDATE foodorder SET status = 3 WHERE orderId = ?")
            .bind(oid)
            .execute(&pool)
            .await?;
    }
    Ok(StatusCode::OK)
}

// ---------- 我的预约 ----------
pub async fn my_reservations(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let user_id = claims.sub;
    let rows = sqlx::query(
        r#"
        SELECT r.revId, r.resId, r.startTime, r.endTime, r.status, r.checkinTime, r.amount,
               res.name as seat_code
        FROM reservation r
        JOIN resource res ON r.resId = res.resId
        WHERE r.userId = ?
        ORDER BY r.startTime DESC
        "#,
    )
    .bind(user_id)
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for row in rows {
        let rev_id: i32 = row.get(0);
        let start_time: chrono::NaiveDateTime = row.get(2);
        let end_time: chrono::NaiveDateTime = row.get(3);
        let status: i32 = row.get(4);
        let checkin_time: Option<chrono::NaiveDateTime> = row.get(5);
        let amount: i64 = row.get(6);
        let seat_code: String = row.get(7);
        let date = start_time.format("%Y-%m-%d").to_string();
        let start_hour = start_time.format("%H").to_string();
        let end_hour = end_time.format("%H").to_string();
        let slots = vec![format!("{}:00-{}:00", start_hour, end_hour)];
        let status_str = match status {
            0 => "待支付",
            1 => "预约成功",
            2 => "进行中",
            3 => "已取消",
            4 => "违约",
            5 => "已完成",
            _ => "待支付",
        };
        result.push(json!({
            "id": rev_id.to_string(),
            "seatCode": seat_code,
            "date": date,
            "slots": slots,
            "status": status_str,
            "fee": cents_to_yuan(amount),
            "checkInAt": checkin_time.map(|t| t.format("%Y-%m-%d %H:%M:%S").to_string()),
            "verifyCode": format!("{:X}", (rev_id as u64) % 0xFFFFFFFF),
        }));
    }
    Ok(Json(result))
}

// ---------- 取消预约 ----------
pub async fn cancel_reservation(
    Path(rev_id): Path<i32>,
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let rev = sqlx::query("SELECT userId, status, startTime FROM reservation WHERE revId = ?")
        .bind(rev_id)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let rev_user_id: i32 = rev.get(0);
    let status: i32 = rev.get(1);
    let start_time: chrono::NaiveDateTime = rev.get(2);
    if rev_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 0 && status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    let now = chrono::Local::now().naive_local();
    if start_time.signed_duration_since(now).num_minutes() < 30 {
        return Err(AppError::BadRequest("预约开始前30分钟内不可取消".into()));
    }
    sqlx::query("UPDATE reservation SET status = 3, cancelTime = ? WHERE revId = ?")
        .bind(now)
        .bind(rev_id)
        .execute(&pool)
        .await?;
    Ok(StatusCode::OK)
}

// ---------- 我的违约记录 ----------
pub async fn my_breach(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let user_id = claims.sub;
    let rows = sqlx::query(
        "SELECT violateTime, reason FROM violation WHERE userId = ? ORDER BY violateTime DESC",
    )
    .bind(user_id)
    .fetch_all(&pool)
    .await?;
    let records = rows
        .into_iter()
        .map(|row| {
            json!({
                "at": row.get::<chrono::NaiveDateTime, _>(0),
                "reason": row.get::<String, _>(1),
            })
        })
        .collect();
    Ok(Json(records))
}

// ---------- 我的候补 ----------
pub async fn my_waitlist(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let user_id = claims.sub;
    let rows = sqlx::query(
        r#"
        SELECT w.waitId, w.startTime, w.endTime, w.createTime, w.status,
               res.name as seat_code
        FROM waitlist w
        JOIN resource res ON w.resId = res.resId
        WHERE w.userId = ? AND w.status != 3
        ORDER BY w.createTime DESC
        "#,
    )
    .bind(user_id)
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for row in rows {
        let wait_id: i32 = row.get(0);
        let start: chrono::NaiveDateTime = row.get(1);
        let end: chrono::NaiveDateTime = row.get(2);
        let create_time: chrono::NaiveDateTime = row.get(3);
        let status: i32 = row.get(4);
        let seat_code: String = row.get(5);
        let date = start.format("%Y-%m-%d").to_string();
        let start_hour = start.format("%H").to_string();
        let end_hour = end.format("%H").to_string();
        let slots = vec![format!("{}:00-{}:00", start_hour, end_hour)];
        let status_str = match status {
            1 => "排队中",
            2 => "已转正",
            3 => "已取消",
            4 => "未成功",
            _ => "排队中",
        };
        result.push(json!({
            "id": wait_id.to_string(),
            "seatCode": seat_code,
            "date": date,
            "slots": slots,
            "status": status_str,
            "createdAt": create_time.format("%Y/%m/%d %H:%M:%S").to_string(),
        }));
    }
    Ok(Json(result))
}

// ---------- 取消候补 ----------
pub async fn cancel_waitlist(
    Path(wait_id): Path<i32>,
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let w = sqlx::query("SELECT userId, status FROM waitlist WHERE waitId = ?")
        .bind(wait_id)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let wait_user_id: i32 = w.get(0);
    let status: i32 = w.get(1);
    if wait_user_id != user_id {
        return Err(AppError::Forbidden);
    }
    if status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query("UPDATE waitlist SET status = 3, cancelTime = ? WHERE waitId = ?")
        .bind(chrono::Local::now().naive_local())
        .bind(wait_id)
        .execute(&pool)
        .await?;
    Ok(StatusCode::OK)
}
