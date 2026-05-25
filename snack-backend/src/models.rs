use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

// ---------- 响应结构 ----------
#[derive(Debug, Serialize)]
pub struct UserInfo {
    pub userId: i32,
    pub phone: String,
    pub realName: String,
    pub userType: i32,
}

#[derive(Debug, Serialize)]
pub struct Product {
    pub prodId: i32,
    pub name: String,
    pub category: i32,
    pub price: f64, // 返回时转为元
    pub stock: i32,
    pub picture: Option<String>,
    pub description: Option<String>,
    pub state: i32,
}

#[derive(Debug, Serialize, FromRow)]
pub struct Seat {
    pub seatId: i32,
    pub area: String,
    pub seatNo: String,
    pub state: i32,
    pub equipment: Option<String>,
}

#[derive(Debug, Serialize, FromRow)]
pub struct Reservation {
    pub revId: i32,
    pub userId: i32,
    pub resId: i32,
    pub startTime: NaiveDateTime,
    pub endTime: NaiveDateTime,
    pub status: i32,
    pub createTime: NaiveDateTime,
}

#[derive(Debug, FromRow)]
pub struct ReservationBasic {
    pub revId: i32,
    pub userId: i32,
    pub state: i32,
}

// ---------- 请求结构 ----------
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub phone: String,
    pub password: String,
    pub realName: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub phone: String,
    pub password: String,
}

pub struct ResetPasswordRequest {
    pub phone: String,
    pub old_password: String,
    pub new_password: String,
}

#[derive(Deserialize)]
pub struct CreateReservationRequest {
    pub res_id: i32,
    pub start_time: String,
    pub end_time: String,
}

#[derive(Deserialize)]
pub struct CancelReservationRequest {
    pub rev_id: i32,
}

#[derive(Deserialize)]
pub struct QuerySeatsRequest {
    pub area: Option<String>,
    pub date: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CreateOrderRequest {
    pub items: Vec<OrderItemInput>,
    pub deliveryType: i32,
    pub revId: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct OrderItemInput {
    pub prodId: i32,
    pub quantity: i32,
}

#[derive(Debug, Deserialize)]
pub struct CheckinRequest {
    pub revId: i32,
}

#[derive(Debug, Deserialize)]
pub struct ProductQuery {
    pub category: Option<i32>,
    pub on_shelf: Option<bool>,
}
