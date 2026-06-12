use crate::auth::{check_password, generate_token, Claims};
use crate::error::{AppError, Result};
use crate::models::*;
use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::Json,
};
use chrono::Utc;
use serde_json::json;
use sqlx::{MySqlPool, Row};

fn cents_to_yuan(cents: i64) -> f64 {
    cents as f64 / 100.0
}

fn yuan_to_cents(yuan: f64) -> i64 {
    (yuan * 100.0).round() as i64
}

// ---------- 管理员登录 ----------
pub async fn admin_login(
    State(pool): State<MySqlPool>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<serde_json::Value>> {
    let row = sqlx::query(
        "SELECT userId, account, realName, userType, password, state FROM users WHERE account = ?",
    )
    .bind(&req.phone)
    .fetch_optional(&pool)
    .await?
    .ok_or(AppError::Unauthorized)?;

    let user_id: i32 = row.get(0);
    let account: String = row.get(1);
    let real_name: String = row.get(2);
    let user_type: i32 = row.get(3);
    let stored_hash: Option<String> = row.get(4);
    let state: i32 = row.get(5);

    if user_type != 2 {
        return Err(AppError::Unauthorized);
    }
    if state != 1 {
        return Err(AppError::Unauthorized);
    }
    let stored_hash = stored_hash.ok_or(AppError::Internal)?;
    if !check_password(&req.password, &stored_hash)? {
        return Err(AppError::Unauthorized);
    }
    let token = generate_token(user_id, &account, user_type)?;
    Ok(Json(json!({
        "token": token,
        "userId": user_id,
        "account": account,
        "realName": real_name,
        "userType": user_type,
    })))
}

// ========== 座位管理 ==========
pub async fn list_seats(
    State(pool): State<MySqlPool>,
    Query(params): Query<serde_json::Value>,
) -> Result<Json<Vec<Resource>>> {
    let seats = sqlx::query_as::<_, Resource>("SELECT * FROM resource ORDER BY resId")
        .fetch_all(&pool)
        .await?;
    Ok(Json(seats))
}

pub async fn create_seat(
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(seat): Json<Resource>,
) -> Result<Json<Resource>> {
    let new_seat = sqlx::query_as::<_, Resource>(
        "INSERT INTO resource (name, type, location, hasSocket, hasLamp, hasBaffle, byWindow, capacity, state)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
         RETURNING *"
    )
    .bind(&seat.name)
    .bind(seat.r#type)
    .bind(&seat.location)
    .bind(seat.hasSocket)
    .bind(seat.hasLamp)
    .bind(seat.hasBaffle)
    .bind(seat.byWindow)
    .bind(seat.capacity)
    .bind(seat.state)
    .fetch_one(&pool)
    .await?;
    Ok(Json(new_seat))
}

pub async fn update_seat(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(update): Json<AdminSeatUpdate>,
) -> Result<Json<Resource>> {
    let mut query = String::from("UPDATE resource SET ");
    let mut updates = vec![];
    let mut binds: Vec<String> = vec![];
    if let Some(name) = update.name {
        updates.push("name = ?");
        binds.push(name);
    }
    if let Some(typ) = update.r#type {
        updates.push("type = ?");
        binds.push(typ.to_string());
    }
    if let Some(loc) = update.location {
        updates.push("location = ?");
        binds.push(loc);
    }
    if let Some(socket) = update.hasSocket {
        updates.push("hasSocket = ?");
        binds.push(socket.to_string());
    }
    if let Some(lamp) = update.hasLamp {
        updates.push("hasLamp = ?");
        binds.push(lamp.to_string());
    }
    if let Some(baffle) = update.hasBaffle {
        updates.push("hasBaffle = ?");
        binds.push(baffle.to_string());
    }
    if let Some(window) = update.byWindow {
        updates.push("byWindow = ?");
        binds.push(window.to_string());
    }
    if let Some(cap) = update.capacity {
        updates.push("capacity = ?");
        binds.push(cap.to_string());
    }
    if let Some(st) = update.state {
        updates.push("state = ?");
        binds.push(st.to_string());
    }
    if updates.is_empty() {
        return Err(AppError::BadRequest("没有要更新的字段".into()));
    }
    query.push_str(&updates.join(", "));
    query.push_str(" WHERE resId = ? RETURNING *");
    let mut q = sqlx::query_as::<_, Resource>(&query);
    for b in binds {
        q = q.bind(b);
    }
    let seat = q.bind(id).fetch_one(&pool).await?;
    Ok(Json(seat))
}

pub async fn delete_seat(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let result = sqlx::query("DELETE FROM resource WHERE resId = ?")
        .bind(id)
        .execute(&pool)
        .await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    Ok(StatusCode::OK)
}

pub async fn update_seat_state(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<serde_json::Value>,
) -> Result<Json<Resource>> {
    let new_state = req["state"].as_i64().ok_or(AppError::BadRequest("需要 state 字段".into()))? as i32;
    let seat = sqlx::query_as::<_, Resource>("UPDATE resource SET state = ? WHERE resId = ? RETURNING *")
        .bind(new_state)
        .bind(id)
        .fetch_one(&pool)
        .await?;
    Ok(Json(seat))
}

// ========== 预约管理（管理员） ==========
pub async fn admin_list_reservations(
    State(pool): State<MySqlPool>,
    Query(params): Query<serde_json::Value>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let phone = params.get("phone").and_then(|v| v.as_str());
    let seat_name = params.get("seat_name").and_then(|v| v.as_str());
    let start_date = params.get("start_date").and_then(|v| v.as_str());
    let end_date = params.get("end_date").and_then(|v| v.as_str());
    let status = params.get("status").and_then(|v| v.as_i64());

    let mut sql = String::from(
        "SELECT r.revId, r.userId, r.resId, r.startTime, r.endTime, r.status, r.createTime, r.cancelTime, r.checkinTime, r.amount,
                u.phone, u.realName, res.name as seat_code
         FROM reservation r
         JOIN users u ON r.userId = u.userId
         JOIN resource res ON r.resId = res.resId
         WHERE 1=1"
    );
    let mut binds = vec![];
    if let Some(ph) = phone {
        sql.push_str(" AND u.phone LIKE ?");
        binds.push(format!("%{}%", ph));
    }
    if let Some(sn) = seat_name {
        sql.push_str(" AND res.name LIKE ?");
        binds.push(format!("%{}%", sn));
    }
    if let Some(sd) = start_date {
        sql.push_str(" AND r.startTime >= ?");
        binds.push(sd.to_string());
    }
    if let Some(ed) = end_date {
        sql.push_str(" AND r.endTime <= ?");
        binds.push(ed.to_string());
    }
    if let Some(st) = status {
        sql.push_str(" AND r.status = ?");
        binds.push(st.to_string());
    }
    sql.push_str(" ORDER BY r.startTime DESC");

    let mut query = sqlx::query(&sql);
    for b in binds {
        query = query.bind(b);
    }
    let rows = query.fetch_all(&pool).await?;
    let mut result = Vec::new();
    for row in rows {
        let rev_id: i32 = row.get(0);
        let user_id: i32 = row.get(1);
        let res_id: i32 = row.get(2);
        let start_time: chrono::NaiveDateTime = row.get(3);
        let end_time: chrono::NaiveDateTime = row.get(4);
        let status: i32 = row.get(5);
        let create_time: chrono::NaiveDateTime = row.get(6);
        let cancel_time: Option<chrono::NaiveDateTime> = row.get(7);
        let checkin_time: Option<chrono::NaiveDateTime> = row.get(8);
        let amount: i64 = row.get(9);
        let phone: String = row.get(10);
        let real_name: String = row.get(11);
        let seat_code: String = row.get(12);
        result.push(json!({
            "revId": rev_id,
            "userId": user_id,
            "resId": res_id,
            "seatCode": seat_code,
            "userPhone": phone,
            "userName": real_name,
            "startTime": start_time,
            "endTime": end_time,
            "status": status,
            "amount": cents_to_yuan(amount),
            "createTime": create_time,
            "cancelTime": cancel_time,
            "checkinTime": checkin_time,
        }));
    }
    Ok(Json(result))
}

pub async fn admin_mark_checkin(
    Path(rev_id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let now = chrono::Local::now().naive_local();
    let result = sqlx::query(
        "UPDATE reservation SET status = 2, checkinTime = ? WHERE revId = ? AND status = 1",
    )
    .bind(now)
    .bind(rev_id)
    .execute(&pool)
    .await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    let order: Option<(i32,)> = sqlx::query_as(
        "SELECT orderId FROM foodorder WHERE revId = ? AND deliveryType = 1 AND status = 2",
    )
    .bind(rev_id)
    .fetch_optional(&pool)
    .await?;
    if let Some((order_id,)) = order {
        sqlx::query("UPDATE foodorder SET status = 3 WHERE orderId = ?")
            .bind(order_id)
            .execute(&pool)
            .await?;
    }
    Ok(StatusCode::OK)
}

pub async fn admin_mark_violation(
    Path(rev_id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let rev = sqlx::query("SELECT userId, status FROM reservation WHERE revId = ?")
        .bind(rev_id)
        .fetch_optional(&pool)
        .await?
        .ok_or(AppError::NotFound)?;
    let rev_user_id: i32 = rev.get(0);
    let status: i32 = rev.get(1);
    if status != 1 {
        return Err(AppError::InvalidOrderStatus);
    }
    let now = chrono::Local::now().naive_local();
    sqlx::query("UPDATE reservation SET status = 4 WHERE revId = ?")
        .bind(rev_id)
        .execute(&pool)
        .await?;
    sqlx::query(
        "INSERT INTO violation (userId, revId, violateTime, reason, handleStatus)
         VALUES (?, ?, ?, '管理员标记违约', 1)",
    )
    .bind(rev_user_id)
    .bind(rev_id)
    .bind(now)
    .execute(&pool)
    .await?;
    Ok(StatusCode::OK)
}

// ========== 订单管理（管理员） ==========
pub async fn admin_list_orders(
    State(pool): State<MySqlPool>,
    Query(params): Query<serde_json::Value>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let phone = params.get("phone").and_then(|v| v.as_str());
    let status = params.get("status").and_then(|v| v.as_i64());

    let mut sql = String::from(
        "SELECT o.orderId, o.orderNo, o.userId, o.revId, o.totalAmount, o.deliveryType, o.status, o.createTime, o.payTime, o.cancelTime,
                u.phone, u.realName
         FROM foodorder o
         JOIN users u ON o.userId = u.userId
         WHERE 1=1"
    );
    let mut binds = vec![];
    if let Some(ph) = phone {
        sql.push_str(" AND u.phone LIKE ?");
        binds.push(format!("%{}%", ph));
    }
    if let Some(st) = status {
        sql.push_str(" AND o.status = ?");
        binds.push(st.to_string());
    }
    sql.push_str(" ORDER BY o.createTime DESC");

    let mut query = sqlx::query(&sql);
    for b in binds {
        query = query.bind(b);
    }
    let rows = query.fetch_all(&pool).await?;
    let mut result = Vec::new();
    for row in rows {
        let order_id: i32 = row.get(0);
        let order_no: String = row.get(1);
        let user_id: i32 = row.get(2);
        let rev_id: Option<i32> = row.get(3);
        let total_cents: i64 = row.get(4);
        let delivery_type: i32 = row.get(5);
        let status: i32 = row.get(6);
        let create_time: chrono::NaiveDateTime = row.get(7);
        let pay_time: Option<chrono::NaiveDateTime> = row.get(8);
        let cancel_time: Option<chrono::NaiveDateTime> = row.get(9);
        let phone: String = row.get(10);
        let real_name: String = row.get(11);
        result.push(json!({
            "orderId": order_id,
            "orderNo": order_no,
            "userId": user_id,
            "userPhone": phone,
            "userName": real_name,
            "revId": rev_id,
            "totalAmount": cents_to_yuan(total_cents),
            "deliveryType": delivery_type,
            "status": status,
            "createTime": create_time,
            "payTime": pay_time,
            "cancelTime": cancel_time,
        }));
    }
    Ok(Json(result))
}

pub async fn admin_update_order_status(
    Path(order_id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<AdminOrderStatusUpdate>,
) -> Result<StatusCode> {
    let now = chrono::Local::now().naive_local();
    let mut query = "UPDATE foodorder SET status = ?".to_string();
    if req.status == 2 {
        query.push_str(", payTime = ?");
    } else if req.status == 5 {
        query.push_str(", cancelTime = ?");
    }
    query.push_str(" WHERE orderId = ?");
    let mut q = sqlx::query(&query).bind(req.status);
    if req.status == 2 {
        q = q.bind(now);
    } else if req.status == 5 {
        q = q.bind(now);
    }
    let result = q.bind(order_id).execute(&pool).await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    Ok(StatusCode::OK)
}

// ========== 商品管理（管理员） ==========
pub async fn admin_list_products(
    State(pool): State<MySqlPool>,
) -> Result<Json<Vec<Product>>> {
    let products = sqlx::query_as::<_, Product>("SELECT * FROM product ORDER BY prodId")
        .fetch_all(&pool)
        .await?;
    Ok(Json(products))
}

pub async fn admin_create_product(
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(mut product): Json<Product>,
) -> Result<Json<Product>> {
    product.price = yuan_to_cents(product.price as f64);
    let new_product = sqlx::query_as::<_, Product>(
        "INSERT INTO product (name, category, price, stock, picture, description, state)
         VALUES (?, ?, ?, ?, ?, ?, ?)
         RETURNING *"
    )
    .bind(&product.name)
    .bind(product.category)
    .bind(product.price)
    .bind(product.stock)
    .bind(&product.picture)
    .bind(&product.description)
    .bind(product.state)
    .fetch_one(&pool)
    .await?;
    Ok(Json(new_product))
}

pub async fn admin_update_product(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(update): Json<AdminProductUpdate>,
) -> Result<Json<Product>> {
    let mut updates = vec![];
    let mut binds: Vec<String> = vec![];
    if let Some(name) = update.name {
        updates.push("name = ?");
        binds.push(name);
    }
    if let Some(cat) = update.category {
        updates.push("category = ?");
        binds.push(cat.to_string());
    }
    if let Some(price) = update.price {
        updates.push("price = ?");
        binds.push(yuan_to_cents(price).to_string());
    }
    if let Some(stock) = update.stock {
        updates.push("stock = ?");
        binds.push(stock.to_string());
    }
    if let Some(pic) = update.picture {
        updates.push("picture = ?");
        binds.push(pic);
    }
    if let Some(desc) = update.description {
        updates.push("description = ?");
        binds.push(desc);
    }
    if let Some(st) = update.state {
        updates.push("state = ?");
        binds.push(st.to_string());
    }
    if updates.is_empty() {
        return Err(AppError::BadRequest("没有要更新的字段".into()));
    }
    let query = format!(
        "UPDATE product SET {} WHERE prodId = ? RETURNING *",
        updates.join(", ")
    );
    let mut q = sqlx::query_as::<_, Product>(&query);
    for b in binds {
        q = q.bind(b);
    }
    let product = q.bind(id).fetch_one(&pool).await?;
    Ok(Json(product))
}

pub async fn admin_update_stock(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<serde_json::Value>,
) -> Result<Json<Product>> {
    let stock = req["stock"].as_i64().ok_or(AppError::BadRequest("需要 stock 字段".into()))? as i32;
    let product = sqlx::query_as::<_, Product>("UPDATE product SET stock = ? WHERE prodId = ? RETURNING *")
        .bind(stock)
        .bind(id)
        .fetch_one(&pool)
        .await?;
    Ok(Json(product))
}

pub async fn admin_update_shelf(
    Path(id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<serde_json::Value>,
) -> Result<Json<Product>> {
    let state = req["state"].as_i64().ok_or(AppError::BadRequest("需要 state 字段".into()))? as i32;
    let product = sqlx::query_as::<_, Product>("UPDATE product SET state = ? WHERE prodId = ? RETURNING *")
        .bind(state)
        .bind(id)
        .fetch_one(&pool)
        .await?;
    Ok(Json(product))
}

// ========== 违约管理 ==========
pub async fn admin_list_violations(
    State(pool): State<MySqlPool>,
    Query(params): Query<serde_json::Value>,
) -> Result<Json<Vec<serde_json::Value>>> {
    let phone = params.get("phone").and_then(|v| v.as_str());
    let handle_status = params.get("handle_status").and_then(|v| v.as_i64());

    let mut sql = String::from(
        "SELECT v.vioId, v.userId, v.revId, v.violateTime, v.reason, v.handleStatus,
                u.phone, u.realName
         FROM violation v
         JOIN users u ON v.userId = u.userId
         WHERE 1=1"
    );
    let mut binds = vec![];
    if let Some(ph) = phone {
        sql.push_str(" AND u.phone LIKE ?");
        binds.push(format!("%{}%", ph));
    }
    if let Some(hs) = handle_status {
        sql.push_str(" AND v.handleStatus = ?");
        binds.push(hs.to_string());
    }
    sql.push_str(" ORDER BY v.violateTime DESC");

    let mut query = sqlx::query(&sql);
    for b in binds {
        query = query.bind(b);
    }
    let rows = query.fetch_all(&pool).await?;
    let mut result = Vec::new();
    for row in rows {
        let vio_id: i32 = row.get(0);
        let user_id: i32 = row.get(1);
        let rev_id: i32 = row.get(2);
        let violate_time: chrono::NaiveDateTime = row.get(3);
        let reason: String = row.get(4);
        let handle_status: i32 = row.get(5);
        let phone: String = row.get(6);
        let real_name: String = row.get(7);
        result.push(json!({
            "vioId": vio_id,
            "userId": user_id,
            "userPhone": phone,
            "userName": real_name,
            "revId": rev_id,
            "violateTime": violate_time,
            "reason": reason,
            "handleStatus": handle_status,
        }));
    }
    Ok(Json(result))
}

pub async fn admin_handle_violation(
    Path(vio_id): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<serde_json::Value>,
) -> Result<StatusCode> {
    let handle_status = req["handleStatus"].as_i64().ok_or(AppError::BadRequest("需要 handleStatus 字段".into()))? as i32;
    let result = sqlx::query("UPDATE violation SET handleStatus = ? WHERE vioId = ?")
        .bind(handle_status)
        .bind(vio_id)
        .execute(&pool)
        .await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    Ok(StatusCode::OK)
}

// ========== 公告管理 ==========
pub async fn list_notices(
    State(pool): State<MySqlPool>,
    Query(params): Query<serde_json::Value>,
) -> Result<Json<Vec<Notice>>> {
    let state = params.get("state").and_then(|v| v.as_i64());
    let mut sql = String::from("SELECT * FROM notice WHERE 1=1");
    let mut binds = vec![];
    if let Some(st) = state {
        sql.push_str(" AND state = ?");
        binds.push(st.to_string());
    }
    sql.push_str(" ORDER BY createTime DESC");
    let mut query = sqlx::query_as::<_, Notice>(&sql);
    for b in binds {
        query = query.bind(b);
    }
    let notices = query.fetch_all(&pool).await?;
    Ok(Json(notices))
}

pub async fn create_notice(
    Extension(claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<AdminNoticeCreate>,
) -> Result<Json<Notice>> {
    let now = chrono::Local::now().naive_local();
    let state = req.state.unwrap_or(1);
    let notice = sqlx::query_as::<_, Notice>(
        "INSERT INTO notice (title, content, createTime, state, userId)
         VALUES (?, ?, ?, ?, ?)
         RETURNING *"
    )
    .bind(&req.title)
    .bind(&req.content)
    .bind(now)
    .bind(state)
    .bind(claims.sub)
    .fetch_one(&pool)
    .await?;
    Ok(Json(notice))
}

pub async fn update_notice(
    Path(nid): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<AdminNoticeUpdate>,
) -> Result<Json<Notice>> {
    let mut updates = vec![];
    let mut binds: Vec<String> = vec![];
    if let Some(title) = req.title {
        updates.push("title = ?");
        binds.push(title);
    }
    if let Some(content) = req.content {
        updates.push("content = ?");
        binds.push(content);
    }
    if let Some(state) = req.state {
        updates.push("state = ?");
        binds.push(state.to_string());
    }
    if updates.is_empty() {
        return Err(AppError::BadRequest("没有要更新的字段".into()));
    }
    let query = format!("UPDATE notice SET {} WHERE nId = ? RETURNING *", updates.join(", "));
    let mut q = sqlx::query_as::<_, Notice>(&query);
    for b in binds {
        q = q.bind(b);
    }
    let notice = q.bind(nid).fetch_one(&pool).await?;
    Ok(Json(notice))
}

pub async fn delete_notice(
    Path(nid): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
) -> Result<StatusCode> {
    let result = sqlx::query("DELETE FROM notice WHERE nId = ?")
        .bind(nid)
        .execute(&pool)
        .await?;
    if result.rows_affected() == 0 {
        return Err(AppError::NotFound);
    }
    Ok(StatusCode::OK)
}

pub async fn update_notice_state(
    Path(nid): Path<i32>,
    Extension(_claims): Extension<Claims>,
    State(pool): State<MySqlPool>,
    Json(req): Json<serde_json::Value>,
) -> Result<Json<Notice>> {
    let state = req["state"].as_i64().ok_or(AppError::BadRequest("需要 state 字段".into()))? as i32;
    let notice = sqlx::query_as::<_, Notice>("UPDATE notice SET state = ? WHERE nId = ? RETURNING *")
        .bind(state)
        .bind(nid)
        .fetch_one(&pool)
        .await?;
    Ok(Json(notice))
}