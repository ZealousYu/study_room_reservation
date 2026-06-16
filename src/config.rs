#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub server_host: String,
    pub server_port: u16,
    pub public_dir: String,
}

impl Config {
    pub fn from_env() -> Self {
        dotenvy::dotenv().ok();
        let server_port = std::env::var("PORT")
            .ok()
            .and_then(|p| p.parse().ok())
            .or_else(|| {
                std::env::var("SERVER_PORT")
                    .ok()
                    .and_then(|p| p.parse().ok())
            })
            .unwrap_or(8080);
        Self {
            database_url: std::env::var("DATABASE_URL").expect("DATABASE_URL must be set"),
            jwt_secret: std::env::var("JWT_SECRET").expect("JWT_SECRET must be set"),
            server_host: std::env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            server_port,
            public_dir: std::env::var("PUBLIC_DIR").unwrap_or_else(|_| "public".to_string()),
        }
    }
}
