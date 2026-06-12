use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

// ---------- 公共模型 ----------
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct User {
    pub userId: i32,
    pub account: String,
    pub password: String,
    pub realName: String,
    pub userType: i32,
    pub phone: Option<String>,
    pub state: i32,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Resource {
    pub resId: i32,
    pub name: String,
    pub r#type: i32,
    pub location: Option<String>,
    pub hasSocket: i8,
    pub hasLamp: i8,
    pub hasBaffle: i8,
    pub byWindow: i8,
    pub capacity: Option<i32>,
    pub state: i32,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Reservation {
    pub revId: i32,
    pub userId: i32,
    pub resId: i32,
    pub startTime: NaiveDateTime,
    pub endTime: NaiveDateTime,
    pub status: i32,
    pub createTime: NaiveDateTime,
    pub cancelTime: Option<NaiveDateTime>,
    pub checkinTime: Option<NaiveDateTime>,
    pub amount: i64, // 单位：分
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Violation {
    pub vioId: i32,
    pub userId: i32,
    pub revId: i32,
    pub violateTime: NaiveDateTime,
    pub reason: String,
    pub handleStatus: i32,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Notice {
    pub nId: i32,
    pub title: String,
    pub content: String,
    pub createTime: NaiveDateTime,
    pub state: i32,
    pub userId: i32,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Product {
    pub prodId: i32,
    pub name: String,
    pub category: i32,
    pub price: i64, // 单位：分
    pub stock: i32,
    pub picture: Option<String>,
    pub description: Option<String>,
    pub state: i32,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct FoodOrder {
    pub orderId: i32,
    pub orderNo: String,
    pub userId: i32,
    pub revId: Option<i32>,
    pub totalAmount: i64,
    pub deliveryType: i32,
    pub status: i32,
    pub createTime: NaiveDateTime,
    pub payTime: Option<NaiveDateTime>,
    pub cancelTime: Option<NaiveDateTime>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct OrderDetail {
    pub ordId: i32,
    pub orderId: i32,
    pub prodId: i32,
    pub quantity: i32,
    pub price: i64,
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

#[derive(Debug, Deserialize)]
pub struct ResetPasswordRequest {
    pub phone: String,
    pub code: String,
    pub new_password: String,
}

#[derive(Debug, Deserialize)]
pub struct CreateOrderItem {
    pub prodId: i32,
    pub quantity: i32,
}

#[derive(Debug, Deserialize)]
pub struct CreateOrderRequest {
    pub items: Vec<CreateOrderItem>,
    pub deliveryType: i32,
    pub revId: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct CheckinRequest {
    pub revId: i32,
}

#[derive(Debug, Deserialize)]
pub struct CreateReservationRequest {
    pub seatCode: String,
    pub date: String,
    pub slots: Vec<String>,
    pub fee: f64,
}

#[derive(Debug, Deserialize)]
pub struct ProductQuery {
    pub category: Option<i32>,
    pub on_shelf: Option<bool>,
}

// 管理员端请求
#[derive(Debug, Deserialize)]
pub struct AdminSeatUpdate {
    pub name: Option<String>,
    pub r#type: Option<i32>,
    pub location: Option<String>,
    pub hasSocket: Option<i8>,
    pub hasLamp: Option<i8>,
    pub hasBaffle: Option<i8>,
    pub byWindow: Option<i8>,
    pub capacity: Option<i32>,
    pub state: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct AdminProductUpdate {
    pub name: Option<String>,
    pub category: Option<i32>,
    pub price: Option<f64>,
    pub stock: Option<i32>,
    pub picture: Option<String>,
    pub description: Option<String>,
    pub state: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct AdminOrderStatusUpdate {
    pub status: i32,
}

#[derive(Debug, Deserialize)]
pub struct AdminNoticeCreate {
    pub title: String,
    pub content: String,
    pub state: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct AdminNoticeUpdate {
    pub title: Option<String>,
    pub content: Option<String>,
    pub state: Option<i32>,
}