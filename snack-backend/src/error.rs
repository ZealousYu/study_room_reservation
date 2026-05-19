use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("数据库错误")]
    DatabaseError(#[from] sqlx::Error),
    #[error("请求参数错误")]
    BadRequest,
    #[error("未授权")]
    Unauthorized,
    #[error("禁止访问")]
    Forbidden,
    #[error("资源不存在")]
    NotFound,
    #[error("库存不足")]
    InsufficientStock,
    #[error("订单状态不允许")]
    InvalidOrderStatus,
    #[error("重复数据")]
    DuplicateEntry,
    #[error("内部错误")]
    InternalError,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, err_msg) = match self {
            AppError::DatabaseError(_) => (StatusCode::INTERNAL_SERVER_ERROR, "数据库错误"),
            AppError::BadRequest => (StatusCode::BAD_REQUEST, "请求参数错误"),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "未授权"),
            AppError::Forbidden => (StatusCode::FORBIDDEN, "禁止访问"),
            AppError::NotFound => (StatusCode::NOT_FOUND, "资源不存在"),
            AppError::InsufficientStock => (StatusCode::BAD_REQUEST, "库存不足"),
            AppError::InvalidOrderStatus => (StatusCode::BAD_REQUEST, "订单状态不允许"),
            AppError::DuplicateEntry => (StatusCode::CONFLICT, "重复数据"),
            AppError::InternalError => (StatusCode::INTERNAL_SERVER_ERROR, "内部错误"),
        };
        (status, Json(json!({ "error": err_msg }))).into_response()
    }
}