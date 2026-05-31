mod auth;
mod config;
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

    let cfg = config::Config::from_env();
    let pool = db::create_pool(&cfg.database_url).await;

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
        // 订单相关
        .route("/api/orders", post(create_order))
        .route("/api/orders", get(get_user_orders))
        .route("/api/orders/:id", get(get_order_detail))
        .route("/api/orders/:id/pay", post(pay_order))
        .route("/api/orders/:id/cancel", post(cancel_order))
        .route("/api/checkin", post(checkin))
        .route("/api/breach", get(get_my_breach))
        .route("/api/reservations", get(get_user_reservations))
        .route("/api/reservations/:id/cancel", post(cancel_reservation))
        .route("/api/waitlist", get(get_user_waitlist))
        .route("/api/waitlist/:id/cancel", post(cancel_waitlist))
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

use axum::{
    middleware,
    routing::{get, post},
    Router,
};
use tower_http::{cors::CorsLayer, services::ServeDir, trace::TraceLayer};
use tower_http::cors::Any;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    tracing_subscriber::fmt::init();

    let cfg = config::Config::from_env();
    let pool = db::create_pool(&cfg.database_url).await;

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // 静态文件服务 (图片)
    let static_assets = ServeDir::new("public");

    // 用户端公开路由
    let public_user_routes = Router::new()
        .route("/api/auth/register", post(handlers::user::register))
        .route("/api/auth/login", post(handlers::user::login))
        .route("/api/reset-password", post(handlers::user::reset_password))
        .route("/api/products", get(handlers::user::list_products));

    // 用户端需要认证的路由
    let protected_user_routes = Router::new()
        .route("/api/orders", post(handlers::user::create_order))
        .route("/api/orders", get(handlers::user::list_orders))
        .route("/api/orders/:id/pay", post(handlers::user::pay_order))
        .route("/api/orders/:id/cancel", post(handlers::user::cancel_order))
        .route("/api/checkin", post(handlers::user::checkin))
        .route("/api/breach", get(handlers::user::my_breach))
        .route("/api/reservations", get(handlers::user::my_reservations))
        .route("/api/reservations/:id/cancel", post(handlers::user::cancel_reservation))
        .route("/api/waitlist", get(handlers::user::my_waitlist))
        .route("/api/waitlist/:id/cancel", post(handlers::user::cancel_waitlist))
        .layer(middleware::from_fn(auth::user_auth_middleware));

    // 管理员公开路由（登录）
    let public_admin_routes = Router::new()
        .route("/api/admin/login", post(handlers::admin::admin_login));

    // 管理员需要认证的路由
    let protected_admin_routes = Router::new()
        // 座位管理
        .route("/api/admin/seats", get(handlers::admin::list_seats))
        .route("/api/admin/seats", post(handlers::admin::create_seat))
        .route("/api/admin/seats/:id", get(handlers::admin::list_seats)) // 复用列表
        .route("/api/admin/seats/:id", post(handlers::admin::update_seat))
        .route("/api/admin/seats/:id", delete(handlers::admin::delete_seat))
        .route("/api/admin/seats/:id/state", post(handlers::admin::update_seat_state))
        // 预约管理
        .route("/api/admin/reservations", get(handlers::admin::admin_list_reservations))
        .route("/api/admin/reservations/:id/checkin", post(handlers::admin::admin_mark_checkin))
        .route("/api/admin/reservations/:id/violation", post(handlers::admin::admin_mark_violation))
        // 订单管理
        .route("/api/admin/orders", get(handlers::admin::admin_list_orders))
        .route("/api/admin/orders/:id/status", post(handlers::admin::admin_update_order_status))
        // 商品管理
        .route("/api/admin/products", get(handlers::admin::admin_list_products))
        .route("/api/admin/products", post(handlers::admin::admin_create_product))
        .route("/api/admin/products/:id", post(handlers::admin::admin_update_product))
        .route("/api/admin/products/:id/stock", post(handlers::admin::admin_update_stock))
        .route("/api/admin/products/:id/shelf", post(handlers::admin::admin_update_shelf))
        // 违约管理
        .route("/api/admin/violations", get(handlers::admin::admin_list_violations))
        .route("/api/admin/violations/:id/handle", post(handlers::admin::admin_handle_violation))
        // 公告管理
        .route("/api/admin/notices", get(handlers::admin::list_notices))
        .route("/api/admin/notices", post(handlers::admin::create_notice))
        .route("/api/admin/notices/:id", post(handlers::admin::update_notice))
        .route("/api/admin/notices/:id", delete(handlers::admin::delete_notice))
        .route("/api/admin/notices/:id/state", post(handlers::admin::update_notice_state))
        .layer(middleware::from_fn(auth::admin_auth_middleware));

    let app = Router::new()
        .merge(public_user_routes)
        .merge(protected_user_routes)
        .merge(public_admin_routes)
        .merge(protected_admin_routes)
        .nest_service("/images", static_assets)
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .with_state(pool);

    let addr = format!("{}:{}", cfg.server_host, cfg.server_port);
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    tracing::info!("Server running on http://{}", addr);
    axum::serve(listener, app).await?;
    Ok(())
}