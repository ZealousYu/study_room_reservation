use sqlx::{mysql::MySqlPoolOptions, MySqlPool};

pub async fn create_pool() -> anyhow::Result<MySqlPool> {
    let database_url = std::env::var("DATABASE_URL")?;
    let pool = MySqlPoolOptions::new()
        .max_connections(10)
        .connect(&database_url)
        .await?;
    Ok(pool)
}