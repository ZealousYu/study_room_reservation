use serde::{Deserialize, Serialize};

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
    pub price: f64,       // 返回时转为元
    pub stock: i32,
    pub picture: Option<String>,
    pub description: Option<String>,
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