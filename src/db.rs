use sqlx::mysql::MySqlPoolOptions;

pub async fn create_pool(database_url: &str) -> sqlx::MySqlPool {
    MySqlPoolOptions::new()
        .max_connections(10)
        .connect(database_url)
        .await
        .expect("Failed to create database pool")
}