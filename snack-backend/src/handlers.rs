use crate::auth::Claims;
use crate::error::AppError;
use crate::models::*;
use axum::debug_handler;
use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::Json,
};
use chrono::{NaiveDateTime, Utc};
use rand::Rng;
use serde_json::json;
use sqlx::{MySqlPool, Row};
use bcrypt::{hash, verify, DEFAULT_COST};

fn cents_to_yuan(cents: i64) -> f64 {
    cents as f64 / 100.0
}

// ---------- 注册 ----------
pub async fn register(
    State(pool): State<MySqlPool>,
    Json(req): Json<RegisterRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    if !req.phone.starts_with('1') || req.phone.len() != 11 {
        return Err(AppError::BadRequest);
    }
    if req.password.len() < 6 {
        return Err(AppError::BadRequest);
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
    let password_hash = hash(&req.password, DEFAULT_COST)
        .map_err(|_| AppError::InternalError)?;
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
    let phone = row.phone.ok_or(AppError::InternalError)?;
    let token = crate::auth::generate_token(row.userId, &phone)?;
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
) -> Result<Json<serde_json::Value>, AppError> {
    let row = sqlx::query!(
        "SELECT userId, phone, realName, userType, password, state 
         FROM users WHERE phone = ?",
        req.phone
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    if row.state != 1 {
        return Err(AppError::Unauthorized);
    }

    let stored_hash = row.password.ok_or(AppError::InternalError)?;

    let is_valid =
        verify(&req.password, &stored_hash).map_err(|_| AppError::InternalError)?;

    if !is_valid {
        return Err(AppError::Unauthorized);
    }

    let phone = row.phone.ok_or(AppError::InternalError)?;
    let token = crate::auth::generate_token(row.userId, &phone)?;

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
) -> Result<Json<serde_json::Value>, AppError> {
    if !req.phone.starts_with('1') || req.phone.len() != 11 {
        return Err(AppError::BadRequest);
    }

    if req.new_password.len() < 6 {
        return Err(AppError::BadRequest);
    }

    let row = sqlx::query!(
        "SELECT userId, password FROM users WHERE phone = ? AND state = 1",
        req.phone
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    let stored_hash = row.password.ok_or(AppError::InternalError)?;
    let is_valid = verify(&req.old_password, &stored_hash)
        .map_err(|_| AppError::InternalError)?;

    if !is_valid {
        return Err(AppError::Unauthorized);
    }

    let new_hash = hash(&req.new_password, DEFAULT_COST)
        .map_err(|_| AppError::InternalError)?;

    sqlx::query!(
        "UPDATE users SET password = ? WHERE userId = ?",
        new_hash,
        row.userId
    )
    .execute(&pool)
    .await?;

    Ok(Json(json!({ "message": "密码重置成功" })))
}

// ---------- 创建预约 ----------
#[debug_handler]
pub async fn create_reservation(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
    Json(req): Json<CreateReservationRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id = claims.sub;

    let start_time = NaiveDateTime::parse_from_str(&req.start_time, "%Y-%m-%d %H:%M:%S")
        .map_err(|_| AppError::BadRequest)?;
    let end_time = NaiveDateTime::parse_from_str(&req.end_time, "%Y-%m-%d %H:%M:%S")
        .map_err(|_| AppError::BadRequest)?;

    if start_time >= end_time || start_time < Utc::now().naive_local() {
        return Err(AppError::BadRequest);
    }

    let conflict = sqlx::query!(
        "SELECT revId FROM reservation 
         WHERE resId = ? AND status = 1
         AND ((startTime <= ? AND endTime > ?) 
              OR (startTime < ? AND endTime >= ?) 
              OR (startTime >= ? AND endTime <= ?))",
        req.res_id,
        start_time, start_time,
        end_time, end_time,
        start_time, end_time
    )
    .fetch_optional(&pool)
    .await?;

    if conflict.is_some() {
        return Err(AppError::BadRequest);
    }

    let existing = sqlx::query!(
        "SELECT revId FROM reservation 
         WHERE userId = ? AND status = 1 AND endTime > NOW()",
        user_id
    )
    .fetch_optional(&pool)
    .await?;

    if existing.is_some() {
        return Err(AppError::BadRequest);
    }

    let now = Utc::now().naive_local();

    let result = sqlx::query!(
        "INSERT INTO reservation (userId, resId, startTime, endTime, status, createTime, amount) 
         VALUES (?, ?, ?, ?, 1, ?, 0.00)",
        user_id,
        req.res_id,
        start_time,
        end_time,
        now
    )
    .execute(&pool)
    .await?;

    let rev_id = result.last_insert_id() as i32;

    Ok(Json(json!({
        "revId": rev_id,
        "resId": req.res_id,
        "startTime": start_time,
        "endTime": end_time,
        "status": 1,
    })))
}

// ---------- 获取我的预约列表 ----------
#[debug_handler]
pub async fn get_my_reservations(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<Vec<serde_json::Value>>, AppError> {
    let user_id = claims.sub;

    let rows = sqlx::query!(
        "SELECT revId, resId, startTime, endTime, status, createTime 
         FROM reservation 
         WHERE userId = ? AND status = 1
         ORDER BY startTime DESC",
        user_id
    )
    .fetch_all(&pool)
    .await?;

    let reservations = rows
        .into_iter()
        .map(|row| {
            json!({
                "revId": row.revId,
                "resId": row.resId,
                "startTime": row.startTime,
                "endTime": row.endTime,
                "status": row.status,
                "createTime": row.createTime,
            })
        })
        .collect();

    Ok(Json(reservations))
}

// ---------- 取消预约 ----------
#[debug_handler]
pub async fn cancel_reservation(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
    Json(req): Json<CancelReservationRequest>,
) -> Result<StatusCode, AppError> {
    let user_id = claims.sub;

    let reservation = sqlx::query!(
        "SELECT revId, userId, status FROM reservation WHERE revId = ?",
        req.rev_id
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;

    if reservation.userId != user_id {
        return Err(AppError::Forbidden);
    }

    if reservation.status != 1 {
        return Err(AppError::BadRequest);
    }

    let now = Utc::now().naive_local();
    let row = sqlx::query!(
        "SELECT startTime FROM reservation WHERE revId = ?",
        req.rev_id
    )
    .fetch_one(&pool)
    .await?;

    let start_time: NaiveDateTime = row.startTime;
    if start_time.signed_duration_since(now).num_minutes() < 30 {
        return Err(AppError::BadRequest);
    }

    sqlx::query!(
        "UPDATE reservation SET status = 0, cancelTime = ? WHERE revId = ?",
        now,
        req.rev_id
    )
    .execute(&pool)
    .await?;

    Ok(StatusCode::OK)
}

// ---------- 获取预约详情 ----------
#[debug_handler]
pub async fn get_reservation_detail(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
    Path(rev_id): Path<i32>,
) -> Result<Json<Reservation>, AppError> {
    let user_id = claims.sub;

    let reservation = sqlx::query_as!(
        Reservation,
        "SELECT revId, userId, resId, startTime, endTime, status, createTime
         FROM reservation
         WHERE revId = ? AND userId = ?",
        rev_id,
        user_id
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;

    Ok(Json(reservation))
}

// ---------- 商品列表 ----------
pub async fn get_products(
    State(pool): State<MySqlPool>,
    Query(params): Query<ProductQuery>,
) -> Result<Json<Vec<Product>>, AppError> {
    let on_shelf = params.on_shelf.unwrap_or(true);
    let mut sql = String::from("SELECT prodId, name, category, price, stock, picture, description, state FROM product WHERE 1=1");
    let mut binds: Vec<String> = vec![];
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
        products.push(Product {
            prodId: prod_id,
            name,
            category,
            price: cents_to_yuan(price_cents),
            stock,
            picture,
            description,
            state,
        });
    }
    Ok(Json(products))
}

pub async fn get_product(
    State(pool): State<MySqlPool>,
    Path(id): Path<i32>,
) -> Result<Json<Product>, AppError> {
    let row = sqlx::query(
        "SELECT prodId, name, category, price, stock, picture, description, state FROM product WHERE prodId = ?"
    )
    .bind(id)
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;
    let prod_id: i32 = row.get(0);
    let name: String = row.get(1);
    let category: i32 = row.get(2);
    let price_cents: i64 = row.get(3);
    let stock: i32 = row.get(4);
    let picture: Option<String> = row.get(5);
    let description: Option<String> = row.get(6);
    let state: i32 = row.get(7);
    Ok(Json(Product {
        prodId: prod_id,
        name,
        category,
        price: cents_to_yuan(price_cents),
        stock,
        picture,
        description,
        state,
    }))
}

// ---------- 创建订单 ----------
#[debug_handler]
pub async fn create_order(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
    Json(order_req): Json<CreateOrderRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id = claims.sub;
    if order_req.items.is_empty() {
        return Err(AppError::BadRequest);
    }
    if order_req.deliveryType != 1 && order_req.deliveryType != 2 {
        return Err(AppError::BadRequest);
    }
    if order_req.deliveryType == 1 && order_req.revId.is_none() {
        return Err(AppError::BadRequest);
    }

    let mut tx = pool.begin().await?;
    let mut total_cents: i64 = 0;
    let mut items_info = Vec::new();

    for item in &order_req.items {
        let prod = sqlx::query!(
            "SELECT prodId, price, stock, state FROM product WHERE prodId = ? FOR UPDATE",
            item.prodId
        )
        .fetch_optional(&mut *tx)
        .await?
        .ok_or(AppError::NotFound)?;
        if prod.state != 1 {
            return Err(AppError::BadRequest);
        }
        if prod.stock < item.quantity {
            return Err(AppError::InsufficientStock);
        }
        let price_cents = prod.price.ok_or(AppError::InternalError)?;
        total_cents += price_cents * item.quantity as i64;
        items_info.push((prod.prodId, item.quantity, price_cents));
    }

    for (prod_id, qty, _) in &items_info {
        sqlx::query!(
            "UPDATE product SET stock = stock - ? WHERE prodId = ?",
            qty,
            prod_id
        )
        .execute(&mut *tx)
        .await?;
    }

    let now = Utc::now();
    let random_suffix: u16 = rand::thread_rng().gen_range(0..10000);
    let order_no = format!(
        "F{}{:03}{:04}",
        now.format("%Y%m%d%H%M%S"),
        user_id,
        random_suffix
    );
    let rev_id = if order_req.deliveryType == 1 {
        order_req.revId
    } else {
        None
    };

    sqlx::query!(
        "INSERT INTO foodorder (orderNo, userId, revId, totalAmount, deliveryType, status, createTime)
         VALUES (?, ?, ?, ?, ?, 1, ?)",
        order_no,
        user_id,
        rev_id,
        total_cents,
        order_req.deliveryType,
        now
    )
    .execute(&mut *tx)
    .await?;

    let order_id = sqlx::query!("SELECT LAST_INSERT_ID() as id")
        .fetch_one(&mut *tx)
        .await?
        .id;

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
        "status": 1
    })))
}

// ---------- 用户订单列表 ----------
pub async fn get_user_orders(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<Vec<serde_json::Value>>, AppError> {
    let user_id = claims.sub;
    let orders = sqlx::query!(
        "SELECT orderId, orderNo, totalAmount, deliveryType, status, createTime, payTime, cancelTime
         FROM foodorder WHERE userId = ? ORDER BY createTime DESC",
        user_id
    )
    .fetch_all(&pool)
    .await?;
    let mut result = Vec::new();
    for o in orders {
        let items = sqlx::query!(
            "SELECT od.prodId, od.quantity, od.price, p.name, p.picture
             FROM orderdetail od
             JOIN product p ON od.prodId = p.prodId
             WHERE od.orderId = ?",
            o.orderId
        )
        .fetch_all(&pool)
        .await?;
        let mut items_json = Vec::new();
        for i in items {
            let price_cents = i.price.ok_or(AppError::InternalError)?;
            items_json.push(json!({
                "prodId": i.prodId,
                "name": i.name,
                "quantity": i.quantity,
                "price": cents_to_yuan(price_cents),
                "picture": i.picture,
            }));
        }
        let total_amount = o.totalAmount.ok_or(AppError::InternalError)?;
        result.push(json!({
            "orderId": o.orderId,
            "orderNo": o.orderNo,
            "totalAmount": cents_to_yuan(total_amount),
            "deliveryType": o.deliveryType,
            "status": o.status,
            "createTime": o.createTime,
            "payTime": o.payTime,
            "cancelTime": o.cancelTime,
            "items": items_json,
        }));
    }
    Ok(Json(result))
}

pub async fn get_order_detail(
    State(pool): State<MySqlPool>,
    Path(order_id): Path<i32>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<serde_json::Value>, AppError> {
    let user_id = claims.sub;
    let order = sqlx::query!(
        "SELECT orderId, orderNo, totalAmount, deliveryType, status, createTime, payTime, cancelTime, userId
         FROM foodorder WHERE orderId = ?",
        order_id
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;
    if order.userId != user_id {
        return Err(AppError::Forbidden);
    }
    let items = sqlx::query!(
        "SELECT od.prodId, od.quantity, od.price, p.name, p.picture
         FROM orderdetail od
         JOIN product p ON od.prodId = p.prodId
         WHERE od.orderId = ?",
        order_id
    )
    .fetch_all(&pool)
    .await?;
    let mut items_json = Vec::new();
    for i in items {
        let price_cents = i.price.ok_or(AppError::InternalError)?;
        items_json.push(json!({
            "prodId": i.prodId,
            "name": i.name,
            "quantity": i.quantity,
            "price": cents_to_yuan(price_cents),
            "picture": i.picture,
        }));
    }
    let total_amount = order.totalAmount.ok_or(AppError::InternalError)?;
    Ok(Json(json!({
        "orderId": order.orderId,
        "orderNo": order.orderNo,
        "totalAmount": cents_to_yuan(total_amount),
        "deliveryType": order.deliveryType,
        "status": order.status,
        "createTime": order.createTime,
        "payTime": order.payTime,
        "cancelTime": order.cancelTime,
        "items": items_json,
    })))
}

// ---------- 支付订单 ----------
pub async fn pay_order(
    State(pool): State<MySqlPool>,
    Path(order_id): Path<i32>,
    Extension(claims): Extension<Claims>,
) -> Result<StatusCode, AppError> {
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
        Utc::now(),
        order_id
    )
    .execute(&mut *tx)
    .await?;
    tx.commit().await?;
    Ok(StatusCode::OK)
}

// ---------- 取消订单 ----------
pub async fn cancel_order(
    State(pool): State<MySqlPool>,
    Path(order_id): Path<i32>,
    Extension(claims): Extension<Claims>,
) -> Result<StatusCode, AppError> {
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
    let items = sqlx::query!(
        "SELECT prodId, quantity FROM orderdetail WHERE orderId = ?",
        order_id
    )
    .fetch_all(&mut *tx)
    .await?;
    for item in items {
        sqlx::query!(
            "UPDATE product SET stock = stock + ? WHERE prodId = ?",
            item.quantity,
            item.prodId
        )
        .execute(&mut *tx)
        .await?;
    }
    sqlx::query!(
        "UPDATE foodorder SET status = 5, cancelTime = ? WHERE orderId = ?",
        Utc::now(),
        order_id
    )
    .execute(&mut *tx)
    .await?;
    tx.commit().await?;
    Ok(StatusCode::OK)
}

// ---------- 打卡 ----------
#[debug_handler]
pub async fn checkin(
    State(pool): State<MySqlPool>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<CheckinRequest>,
) -> Result<StatusCode, AppError> {
    let user_id = claims.sub;

    let rev = sqlx::query!(
        "SELECT userId FROM reservation WHERE revId = ?",
        payload.revId
    )
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::NotFound)?;

    if rev.userId != user_id {
        return Err(AppError::Forbidden);
    }

    sqlx::query!(
        "UPDATE foodorder 
         SET status = 3 
         WHERE userId = ? AND revId = ? AND deliveryType = 1 AND status = 2",
        user_id,
        payload.revId
    )
    .execute(&pool)
    .await?;

    Ok(StatusCode::OK)
}

pub async fn get_my_breach(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<serde_json::Value>>, AppError> {
    let user_id = claims.sub;

    let rows = sqlx::query!(
        "SELECT violateTime, reason 
         FROM violation 
         WHERE userId = ? 
         ORDER BY violateTime DESC",
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
