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
            database_url: database_url_from_env(),
            jwt_secret: std::env::var("JWT_SECRET").unwrap_or_else(|_| {
                eprintln!(
                    "ERROR: JWT_SECRET is not set. In Railway: backend service → Variables → add JWT_SECRET (random long string)."
                );
                std::process::exit(1);
            }),
            server_host: std::env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            server_port,
            public_dir: std::env::var("PUBLIC_DIR").unwrap_or_else(|_| "public".to_string()),
        }
    }
}

/// Railway MySQL 默认提供 MYSQL_URL；也支持标准 DATABASE_URL。
fn database_url_from_env() -> String {
    if let Ok(url) = std::env::var("DATABASE_URL") {
        if !url.is_empty() {
            return url;
        }
    }
    if let Ok(url) = std::env::var("MYSQL_URL") {
        if !url.is_empty() {
            tracing::info!("Using MYSQL_URL as database connection string");
            return url;
        }
    }
    if let Ok(url) = mysql_url_from_parts() {
        tracing::info!("Built database URL from MYSQLHOST/MYSQLUSER/...");
        return url;
    }
    eprintln!(
        "ERROR: No database URL found. Set on the **backend web service** (not MySQL):\n\
         • DATABASE_URL — Add Reference → MySQL service → MYSQL_URL\n\
         • or link MySQL so MYSQL_URL is injected into this service"
    );
    std::process::exit(1);
}

fn mysql_url_from_parts() -> Result<String, std::env::VarError> {
    let host = std::env::var("MYSQLHOST")?;
    let port = std::env::var("MYSQLPORT").unwrap_or_else(|_| "3306".to_string());
    let user = std::env::var("MYSQLUSER")?;
    let pass = std::env::var("MYSQLPASSWORD")?;
    let db = std::env::var("MYSQLDATABASE")?;
    Ok(format!("mysql://{}:{}@{}:{}/{}", user, pass, host, port, db))
}
