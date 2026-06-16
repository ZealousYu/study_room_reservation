use sqlx::mysql::MySqlPoolOptions;
use std::time::Duration;

/// 懒连接：先启动 HTTP 服务，首次查询时再连库（避免 Railway 健康检查超时）。
pub fn create_pool(database_url: &str) -> sqlx::MySqlPool {
    MySqlPoolOptions::new()
        .max_connections(10)
        .acquire_timeout(Duration::from_secs(30))
        .connect_lazy(database_url)
        .expect("Invalid DATABASE_URL")
}