use crate::error::AppError;
use axum::{
    extract::Request,
    middleware::Next,
    response::Response,
};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::env;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: i32,
    pub phone: String,
    pub exp: usize,
}

pub fn generate_token(user_id: i32, phone: &str) -> Result<String, AppError> {
    let secret = env::var("JWT_SECRET").map_err(|_| AppError::InternalError)?;
    let exp = Utc::now() + Duration::hours(24);
    let claims = Claims {
        sub: user_id,
        phone: phone.to_string(),
        exp: exp.timestamp() as usize,
    };
    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|_| AppError::InternalError)
}

pub fn verify_token(token: &str) -> Result<Claims, AppError> {
    let secret = env::var("JWT_SECRET").map_err(|_| AppError::InternalError)?;
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|_| AppError::Unauthorized)
}

pub async fn auth_middleware(
    mut req: Request,
    next: Next,
) -> Result<Response, AppError> {
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
    req.extensions_mut().insert(claims);
    Ok(next.run(req).await)
}