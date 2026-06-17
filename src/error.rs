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
    Database(#[from] sqlx::Error),
    #[error("请求参数错误")]
    BadRequest(String),
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
    Internal,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            AppError::Database(e) => {
                tracing::error!("Database error: {}", e);
                (StatusCode::INTERNAL_SERVER_ERROR, "数据库错误".to_string())
            }
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "未授权".to_string()),
            AppError::Forbidden => (StatusCode::FORBIDDEN, "无权限".to_string()),
            AppError::NotFound => (StatusCode::NOT_FOUND, "资源不存在".to_string()),
            AppError::InsufficientStock => (StatusCode::BAD_REQUEST, "库存不足".to_string()),
            AppError::InvalidOrderStatus => (StatusCode::BAD_REQUEST, "订单状态不允许".to_string()),
            AppError::DuplicateEntry => (StatusCode::CONFLICT, "数据已存在".to_string()),
            AppError::Internal => (StatusCode::INTERNAL_SERVER_ERROR, "服务器内部错误".to_string()),
        };
        (status, Json(json!({ "error": message }))).into_response()
    }
}

pub type Result<T> = std::result::Result<T, AppError>;

/// 将常见 MySQL 错误转为业务错误，避免一律返回「数据库错误」。
pub fn from_sqlx(err: sqlx::Error) -> AppError {
    if let sqlx::Error::Database(db) = &err {
        let msg = db.message();
        if db.code().as_deref() == Some("23000") || msg.contains("Duplicate entry") {
            return AppError::DuplicateEntry;
        }
        if msg.contains("Data too long for column 'password'") {
            return AppError::BadRequest(
                "密码字段长度不足，请执行 sql/migrate_users_password_varchar256.sql 升级数据库".into(),
            );
        }
    }
    AppError::Database(err)
}