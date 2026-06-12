mod auth;
mod config;
mod db;
mod error;
mod handles;
mod models;

use axum::{
    middleware,
    routing::{delete, get, post},
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

    let static_assets = ServeDir::new("public");

    let public_user_routes = Router::new()
        .route("/api/auth/register", post(handles::user::register))
        .route("/api/auth/login", post(handles::user::login))
        .route("/api/reset-password", post(handles::user::reset_password))
        .route("/api/products", get(handles::user::list_products))
        .route("/api/notices", get(handles::user::list_public_notices));

    let protected_user_routes = Router::new()
        .route("/api/orders", post(handles::user::create_order))
        .route("/api/orders", get(handles::user::list_orders))
        .route("/api/orders/:id/pay", post(handles::user::pay_order))
        .route("/api/orders/:id/cancel", post(handles::user::cancel_order))
        .route("/api/checkin", post(handles::user::checkin))
        .route("/api/breach", get(handles::user::my_breach))
        .route("/api/reservations", get(handles::user::my_reservations))
        .route("/api/reservations", post(handles::user::create_reservation))
        .route("/api/reservations/:id/pay", post(handles::user::pay_reservation))
        .route("/api/reservations/:id/cancel", post(handles::user::cancel_reservation))
        .route("/api/waitlist", get(handles::user::my_waitlist))
        .route("/api/waitlist/:id/cancel", post(handles::user::cancel_waitlist))
        .layer(middleware::from_fn(auth::user_auth_middleware));

    let public_admin_routes = Router::new()
        .route("/api/admin/login", post(handles::admin::admin_login));

    let protected_admin_routes = Router::new()
        .route("/api/admin/seats", get(handles::admin::list_seats))
        .route("/api/admin/seats", post(handles::admin::create_seat))
        .route("/api/admin/seats/:id", get(handles::admin::list_seats))
        .route("/api/admin/seats/:id", post(handles::admin::update_seat))
        .route("/api/admin/seats/:id", delete(handles::admin::delete_seat))
        .route("/api/admin/seats/:id/state", post(handles::admin::update_seat_state))
        .route("/api/admin/reservations", get(handles::admin::admin_list_reservations))
        .route("/api/admin/reservations/:id/checkin", post(handles::admin::admin_mark_checkin))
        .route("/api/admin/reservations/:id/violation", post(handles::admin::admin_mark_violation))
        .route("/api/admin/orders", get(handles::admin::admin_list_orders))
        .route("/api/admin/orders/:id/status", post(handles::admin::admin_update_order_status))
        .route("/api/admin/products", get(handles::admin::admin_list_products))
        .route("/api/admin/products", post(handles::admin::admin_create_product))
        .route("/api/admin/products/:id", post(handles::admin::admin_update_product))
        .route("/api/admin/products/:id/stock", post(handles::admin::admin_update_stock))
        .route("/api/admin/products/:id/shelf", post(handles::admin::admin_update_shelf))
        .route("/api/admin/violations", get(handles::admin::admin_list_violations))
        .route("/api/admin/violations/:id/handle", post(handles::admin::admin_handle_violation))
        .route("/api/admin/notices", get(handles::admin::list_notices))
        .route("/api/admin/notices", post(handles::admin::create_notice))
        .route("/api/admin/notices/:id", post(handles::admin::update_notice))
        .route("/api/admin/notices/:id", delete(handles::admin::delete_notice))
        .route("/api/admin/notices/:id/state", post(handles::admin::update_notice_state))
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
