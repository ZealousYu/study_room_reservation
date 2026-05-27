mod auth;
mod db;
mod error;
mod handlers;
mod models;

use axum::{
    middleware,
    routing::{get, post},
    Router,
};
use handlers::*;
use tower_http::{cors::CorsLayer, services::ServeDir};
use tower_http::cors::Any;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    tracing_subscriber::fmt::init();

    let pool = db::create_pool().await?;

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let static_assets = ServeDir::new("public");

    // 公开路由（无需认证）
    let public_routes = Router::new()
        .route("/api/auth/register", post(register))
        .route("/api/auth/login", post(login))
        .route("/api/reset-password", post(reset_password))
        .route("/api/products", get(get_products))
        .route("/api/products/:id", get(get_product));

    // 需要认证的路由
    let protected_routes = Router::new()
        .route("/api/orders", post(create_order))
        .route("/api/orders", get(get_user_orders))
        .route("/api/orders/:id", get(get_order_detail))
        .route("/api/orders/:id/pay", post(pay_order))
        .route("/api/orders/:id/cancel", post(cancel_order))
        .route("/api/checkin", post(checkin))
        .route("/api/breach", get(get_my_breach))   // 新增这一行
        .layer(middleware::from_fn(auth::auth_middleware));

    let app = Router::new()
        .merge(public_routes)
        .merge(protected_routes)
        .nest_service("/images", static_assets)
        .layer(cors)
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await?;
    println!("Server running on http://localhost:8080");
    axum::serve(listener, app).await?;
    Ok(())
}