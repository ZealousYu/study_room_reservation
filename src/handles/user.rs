use crate::auth::{generate_token, Claims};
use crate::error::{AppError, Result};
use crate::models::*;
use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::Json,
};
use bcrypt::{hash, verify, DEFAULT_COST};
use chrono::Utc;
use rand::Rng;
use serde_json::json;
use sqlx::MySqlPool;

fn cents_to_yuan(cents: i64) -> f64 {
    cents as f64 / 100.0
}

fn yuan_to_cents(yuan: f64) -> i64 {
    (yuan * 100.0).round() as i64
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

    let existing = sqlx::query!("SELECT userId FROM users WHERE phone = ?", req.phone)
        .fetch_optional(&pool)
        .await?;
    if existing.is_some() {
        return Err(AppError::DuplicateEntry);
    }

    let account = format!("u{}", &req.phone[3..]);
    let password_hash = hash(&req.password, DEFAULT_COST).map_err(|_| AppError::Internal)?;

    sqlx::query!(
        "INSERT INTO users (account, password, realName, userType, phone, state) VALUES (?, ?, ?, 1, ?, 1)",
        account,
        password_hash,
        real_name,
        req.phone
    )
    .execute(&pool)
    .await?;

    let row = sqlx::query!(
        "SELECT userId, phone, realName, userType FROM users WHERE phone = ?",
        req.phone
    )
    .fetch_one(&pool)
    .await?;
    let phone = row.phone.ok_or(AppError::Internal)?;
    let token = generate_token(row.userId, &phone, 1)?;

    Ok(Json(json!({
        "token": token,
        "user": {
            "userId": row.userId,
            "phone": phone,
            "realName": row.realName,
            "userType": row.userType,
        }
    })))
}

// ---------- 登录 ----------
pub async fn login(
    State(pool): State<MySqlPool>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<serde_json::Value>> {
    let row = sqlx::query!(
        "SELECT userId, phone, realName, userType, password, state FROM users WHERE phone = ?",
        req.phone
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    if row.state != 1 {
        return Err(AppError::Unauthorized);
    }

    let stored_hash = row.password.ok_or(AppError::Internal)?;
    let is_valid = verify(&req.password, &stored_hash).map_err(|_| AppError::Internal)?;
    if !is_valid {
        return Err(AppError::Unauthorized);
    }

    let phone = row.phone.ok_or(AppError::Internal)?;
    let token = generate_token(row.userId, &phone, row.userType)?;

    Ok(Json(json!({
        "token": token,
        "user": {
            "userId": row.userId,
            "phone": phone,
            "realName": row.realName,
            "userType": row.userType,
        }
    })))
}

// ---------- 重置密码 ----------
pub async fn reset_password(
    State(pool): State<MySqlPool>,
    Json(req): Json<ResetPasswordRequest>,
) -> Result<Json<serde_json::Value>> {
    // 演示环境固定验证码 123456
    if req.code != "123456" {
        return Err(AppError::BadRequest("验证码错误".into()));
    }

    let row = sqlx::query!(
        "SELECT userId FROM users WHERE phone = ? AND state = 1",
        req.phone
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    let new_hash = hash(&req.new_password, DEFAULT_COST).map_err(|_| AppError::Internal)?;
    sqlx::query!("UPDATE users SET password = ? WHERE userId = ?", new_hash, row.userId)
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
    let mut sql = String::from("SELECT prodId, name, category, price, stock, picture, description, state FROM product WHERE 1=1");
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
        let prod_id: i32 = row.get(0);
        let name: String = row.get(1);
        let category: i32 = row.get(2);
        let price_cents: i64 = row.get(3);
        let stock: i32 = row.get(4);
        let picture: Option<String> = row.get(5);
        let description: Option<String> = row.get(6);
        let state: i32 = row.get(7);
        products.push(json!({
            "prodId": prod_id,
            "name": name,
            "category": category,
            "price": cents_to_yuan(price_cents),
            "stock": stock,
            "picture": picture,
            "description": description,
            "state": state,
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
    let mut total_cents = 0;
    let mut items_info = Vec::new();

    for item in &req.items {
        let prod = sqlx::query!(
            "SELECT prodId, price, stock, state FROM product WHERE prodId = ? FOR UPDATE",
            item.prodId
        )
        .fetch_optional(&mut *tx)
        .await?
        .ok_or(AppError::NotFound)?;
        if prod.state != 1 {
            return Err(AppError::BadRequest("商品已下架".into()));
        }
        if prod.stock < item.quantity {
            return Err(AppError::InsufficientStock);
        }
        total_cents += prod.price * item.quantity as i64;
        items_info.push((prod.prodId, item.quantity, prod.price));
    }

    for (prod_id, qty, _) in &items_info {
        sqlx::query!("UPDATE product SET stock = stock - ? WHERE prodId = ?", qty, prod_id)
            .execute(&mut *tx)
            .await?;
    }

    let now = chrono::Local::now().naive_local();
    let random_suffix: u32 = rand::thread_rng().gen_range(0..10000);
    let order_no = format!("F{}{:03}{:04}", now.format("%Y%m%d%H%M%S"), user_id, random_suffix);

    let order_id = sqlx::query!(
        "INSERT INTO foodorder (orderNo, userId, revId, totalAmount, deliveryType, status, createTime)
         VALUES (?, ?, ?, ?, ?, 1, ?)",
        order_no,
        user_id,
        req.revId,
        total_cents,
        req.deliveryType,
        now
    )
    .execute(&mut *tx)
    .await?
    .last_insert_id();

    for (prod_id, qty, price_cents) in items_info {
        sqlx::query!(
            "INSERT INTO orderdetail (orderId, prodId, quantity, price) VALUES (?, ?, ?, ?)",
            order_id,
            prod_id,
            qty,
            price_cents
        )
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
    let rows = sqlx::query!(
        "SELECT orderId, orderNo, totalAmount, deliveryType, status, createTime, payTime, cancelTime
         FROM foodorder WHERE userId = ? ORDER BY createTime DESC",
        user_id
    )
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for o in rows {
        let items = sqlx::query!(
            "SELECT od.prodId, od.quantity, od.price, p.name, p.picture
             FROM orderdetail od
             JOIN product p ON od.prodId = p.prodId
             WHERE od.orderId = ?",
            o.orderId
        )
        .fetch_all(&pool)
        .await?;
        let items_json = items
            .into_iter()
            .map(|i| {
                json!({
                    "product": {
                        "id": i.prodId.to_string(),
                        "name": i.name,
                        "price": cents_to_yuan(i.price.unwrap_or(0)),
                    },
                    "qty": i.quantity,
                })
            })
            .collect::<Vec<_>>();
        result.push(json!({
            "id": o.orderId.to_string(),
            "orderNo": o.orderNo,
            "createdAt": o.createTime,
            "items": items_json,
            "total": cents_to_yuan(o.totalAmount.unwrap_or(0)),
            "delivery": if o.deliveryType == 1 { "配送至座位" } else { "吧台自取" },
            "status": match o.status {
                1 => "待支付",
                2 => "已支付",
                3 => "制作中",
                4 => "已完成",
                5 => "已取消",
                _ => "待支付",
            },
            "deliveryStatus": "none", // 前端自行处理
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
    let order = sqlx::query!(
        "SELECT userId, status FROM foodorder WHERE orderId = ? FOR UPDATE",
        order_id
    )
    .fetch_optional(&mut *tx)
    .await?
    .ok_or(AppError::NotFound)?;
    if order.userId != user_id {
        return Err(AppError::Forbidden);
    }
    if order.status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query!(
        "UPDATE foodorder SET status = 2, payTime = ? WHERE orderId = ?",
        chrono::Local::now().naive_local(),
        order_id
    )
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
    let order = sqlx::query!(
        "SELECT userId, status FROM foodorder WHERE orderId = ? FOR UPDATE",
        order_id
    )
    .fetch_optional(&mut *tx)
    .await?
    .ok_or(AppError::NotFound)?;
    if order.userId != user_id {
        return Err(AppError::Forbidden);
    }
    if order.status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    // 恢复库存
    let items = sqlx::query!("SELECT prodId, quantity FROM orderdetail WHERE orderId = ?", order_id)
        .fetch_all(&mut *tx)
        .await?;
    for item in items {
        sqlx::query!("UPDATE product SET stock = stock + ? WHERE prodId = ?", item.quantity, item.prodId)
            .execute(&mut *tx)
            .await?;
    }
    sqlx::query!(
        "UPDATE foodorder SET status = 5, cancelTime = ? WHERE orderId = ?",
        chrono::Local::now().naive_local(),
        order_id
    )
    .execute(&mut *tx)
    .await?;
    tx.commit().await?;
    Ok(StatusCode::OK)
}

// ---------- 打卡 ----------
pub async fn checkin(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<CheckinRequest>,
) -> Result<StatusCode> {
    let user_id = claims.sub;
    let rev = sqlx::query!(
        "SELECT userId, status FROM reservation WHERE revId = ?",
        req.revId
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;
    if rev.userId != user_id {
        return Err(AppError::Forbidden);
    }
    if rev.status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query!(
        "UPDATE reservation SET status = 2, checkinTime = ? WHERE revId = ?",
        chrono::Local::now().naive_local(),
        req.revId
    )
    .execute(&pool)
    .await?;
    // 检查是否有配送订单需要开始制作
    let order = sqlx::query!(
        "SELECT orderId FROM foodorder WHERE userId = ? AND revId = ? AND deliveryType = 1 AND status = 2",
        user_id,
        req.revId
    )
    .fetch_optional(&pool)
    .await?;
    if let Some(o) = order {
        sqlx::query!("UPDATE foodorder SET status = 3 WHERE orderId = ?", o.orderId)
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
    let rows = sqlx::query!(
        r#"
        SELECT r.revId, r.resId, r.startTime, r.endTime, r.status, r.checkinTime, r.amount,
               res.name as seat_code
        FROM reservation r
        JOIN resource res ON r.resId = res.resId
        WHERE r.userId = ?
        ORDER BY r.startTime DESC
        "#,
        user_id
    )
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for row in rows {
        let start_time = row.startTime;
        let end_time = row.endTime;
        let date = start_time.format("%Y-%m-%d").to_string();
        let start_hour = start_time.format("%H").to_string();
        let end_hour = end_time.format("%H").to_string();
        let slots = vec![format!("{}:00-{}:00", start_hour, end_hour)];
        let status_str = match row.status {
            0 => "待支付",
            1 => "预约成功",
            2 => "进行中",
            3 => "已取消",
            4 => "违约",
            5 => "已完成",
            _ => "待支付",
        };
        result.push(json!({
            "id": row.revId.to_string(),
            "seatCode": row.seat_code,
            "date": date,
            "slots": slots,
            "status": status_str,
            "fee": cents_to_yuan(row.amount),
            "checkInAt": row.checkinTime.map(|t| t.format("%Y-%m-%d %H:%M:%S").to_string()),
            "verifyCode": format!("{:X}", (row.revId as u64) % 0xFFFFFFFF),
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
    let rev = sqlx::query!(
        "SELECT userId, status, startTime FROM reservation WHERE revId = ?",
        rev_id
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;
    if rev.userId != user_id {
        return Err(AppError::Forbidden);
    }
    if rev.status != 0 && rev.status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    // 检查取消截止时间（预约开始前30分钟）
    let now = chrono::Local::now().naive_local();
    if rev.startTime.signed_duration_since(now).num_minutes() < 30 {
        return Err(AppError::BadRequest("预约开始前30分钟内不可取消".into()));
    }
    sqlx::query!(
        "UPDATE reservation SET status = 3, cancelTime = ? WHERE revId = ?",
        now,
        rev_id
    )
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
    let rows = sqlx::query!(
        "SELECT violateTime, reason FROM violation WHERE userId = ? ORDER BY violateTime DESC",
        user_id
    )
    .fetch_all(&pool)
    .await?;
    let records = rows
        .into_iter()
        .map(|row| {
            json!({
                "at": row.violateTime,
                "reason": row.reason,
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
    let rows = sqlx::query!(
        r#"
        SELECT w.waitId, w.startTime, w.endTime, w.createTime, w.status,
               res.name as seat_code
        FROM waitlist w
        JOIN resource res ON w.resId = res.resId
        WHERE w.userId = ? AND w.status != 3
        ORDER BY w.createTime DESC
        "#,
        user_id
    )
    .fetch_all(&pool)
    .await?;

    let mut result = Vec::new();
    for row in rows {
        let start = row.startTime;
        let end = row.endTime;
        let date = start.format("%Y-%m-%d").to_string();
        let start_hour = start.format("%H").to_string();
        let end_hour = end.format("%H").to_string();
        let slots = vec![format!("{}:00-{}:00", start_hour, end_hour)];
        let status_str = match row.status {
            1 => "排队中",
            2 => "已转正",
            3 => "已取消",
            4 => "未成功",
            _ => "排队中",
        };
        result.push(json!({
            "id": row.waitId.to_string(),
            "seatCode": row.seat_code,
            "date": date,
            "slots": slots,
            "status": status_str,
            "createdAt": row.createTime.format("%Y/%m/%d %H:%M:%S").to_string(),
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
    let w = sqlx::query!(
        "SELECT userId, status FROM waitlist WHERE waitId = ?",
        wait_id
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;
    if w.userId != user_id {
        return Err(AppError::Forbidden);
    }
    if w.status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    sqlx::query!(
        "UPDATE waitlist SET status = 3, cancelTime = ? WHERE waitId = ?",
        chrono::Local::now().naive_local(),
        wait_id
    )
    .execute(&pool)
    .await?;
    Ok(StatusCode::OK)
}