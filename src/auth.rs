use crate::error::AppError;
use axum::{
    extract::Request,
    middleware::Next,
    response::Response,
};
use bcrypt::verify;
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::env;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: i32,       // user_id
    pub phone: String,
    pub user_type: i32, // 1=普通用户, 2=管理员
    pub exp: usize,
}

pub fn generate_token(user_id: i32, phone: &str, user_type: i32) -> Result<String, AppError> {
    let secret = env::var("JWT_SECRET").map_err(|_| AppError::Internal)?;
    let exp = (Utc::now() + Duration::hours(24)).timestamp() as usize;
    let claims = Claims {
        sub: user_id,
        phone: phone.to_string(),
        user_type,
        exp,
    };
    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|_| AppError::Internal)
}

fn verify_token(token: &str) -> Result<Claims, AppError> {
    let secret = env::var("JWT_SECRET").map_err(|_| AppError::Internal)?;
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|_| AppError::Unauthorized)
}

/// 兼容 SQL 种子数据中的明文密码，以及注册后存入的 bcrypt 哈希。
pub fn check_password(input: &str, stored: &str) -> Result<bool, AppError> {
    if stored.starts_with("$2a$") || stored.starts_with("$2b$") || stored.starts_with("$2y$") {
        verify(input, stored).map_err(|_| AppError::Internal)
    } else {
        Ok(input == stored)
    }
}

pub async fn user_auth_middleware(mut req: Request, next: Next) -> Result<Response, AppError> {
    let headers = req.headers();
    let auth_header = headers
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or(AppError::Unauthorized)?;
    if !auth_header.starts_with("Bearer ") {
        return Err(AppError::Unauthorized);
    }
    let token = &auth_header[7..];
    let claims = verify_token(token)?;
    if claims.user_type != 1 {
        return Err(AppError::Forbidden);
    }
    req.extensions_mut().insert(claims);
    Ok(next.run(req).await)
}

pub async fn admin_auth_middleware(mut req: Request, next: Next) -> Result<Response, AppError> {
    let headers = req.headers();
    let auth_header = headers
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or(AppError::Unauthorized)?;
    if !auth_header.starts_with("Bearer ") {
        return Err(AppError::Unauthorized);
    }
    let token = &auth_header[7..];
    let claims = verify_token(token)?;
    if claims.user_type != 2 {
        return Err(AppError::Forbidden);
    }
    req.extensions_mut().insert(claims);
    Ok(next.run(req).await)
}