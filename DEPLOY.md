# 部署指南（Railway 后端 + Netlify 前端）

手机访问 [Netlify 站点](https://studyroombookingsystem.netlify.app/) 需要：**公网后端 API** + **前端构建时指向该 API**。

---

## 架构

```
手机/浏览器 → Netlify（React 静态页）
              ↓ VITE_API_URL
         Railway（Rust API + MySQL）
```

---

## 一、部署后端到 Railway

### 1. 注册并创建项目

1. 打开 [Railway](https://railway.app/) 并登录（可用 GitHub）
2. **New Project** → **Deploy from GitHub repo**
3. 选择仓库 `study_room_reservation`（需先推到 GitHub）

### 2. 添加 MySQL

1. 在项目里点击 **+ New** → **Database** → **MySQL**
2. 等待 MySQL 服务就绪
3. 点 MySQL 服务 → **Variables** → 复制 `MYSQL_URL` 或拼接为 `DATABASE_URL`

Railway MySQL 的 `DATABASE_URL` 通常类似：

```
mysql://root:密码@containers-us-west-xxx.railway.app:端口/railway
```

在 **后端 Web 服务**（不是 MySQL 服务）的 **Variables** 里添加：

| 变量 | 值 |
|------|-----|
| `DATABASE_URL` | 在后端服务 Variables 点 **Add Reference** → 选 MySQL 服务 → `MYSQL_URL`（**不要**填到 MySQL 服务上） |
| `JWT_SECRET` | 随机长字符串（必填，否则进程启动即退出） |
| `PUBLIC_DIR` | `public`（Docker 镜像内已包含图片） |

Railway 会自动注入 `PORT`，无需设置 `SERVER_PORT`。`SERVER_HOST` 默认为 `0.0.0.0`。

**健康检查失败常见原因：** 未在后端服务配置 `DATABASE_URL` / `JWT_SECRET`，或 `DATABASE_URL` 引用了错误的服务变量。

### 3. 导入数据库

在本机（需能连 Railway MySQL，可用 Railway 提供的公网连接信息）：

```bash
mysql -h <主机> -P <端口> -u root -p <数据库名> < study_room_reservation.sql
```

或在 Railway MySQL 面板使用 **Data** / **Query** 导入（大文件可能较慢）。

导入后可用测试账号：`18843917510` / `111111`，管理员 `gft141` / `141414`。

### 4. 配置 Web 服务

1. 确保仓库根目录有 `Dockerfile` 和 `railway.json`
2. Railway 检测到 Dockerfile 后会自动构建
3. 部署成功后打开 **Settings → Networking → Generate Domain**
4. 得到类似 `https://study-room-backend-production.up.railway.app`
5. 验证：浏览器或终端访问

```bash
curl https://你的域名.up.railway.app/api/health
# 应返回 {"status":"ok"}

curl https://你的域名.up.railway.app/api/products
# 应返回 JSON 商品列表
```

---

## 二、配置 Netlify 前端

### 1. 环境变量（关键）

Netlify 控制台 → 你的站点 → **Site configuration** → **Environment variables**：

| 变量名 | 值 |
|--------|-----|
| `VITE_API_URL` | `https://你的-railway-域名.up.railway.app`（**不要**末尾斜杠） |

### 2. 重新部署

**Deploys** → **Trigger deploy** → **Clear cache and deploy site**

（改 `VITE_API_URL` 后必须重新构建，否则仍是旧的 `localhost:8080`。）

### 3. 验证

手机打开 https://studyroombookingsystem.netlify.app/ ，用 `18843917510` / `111111` 登录。

---

## 三、本地开发（不变）

```bash
# 终端 1
cd study_room_reservation
cargo run

# 终端 2
cd StudyroomBookingSystem-main
npm run dev
```

本地不设置 `VITE_API_URL` 时默认 `http://localhost:8080`。

`.env` 建议：

```env
DATABASE_URL=mysql://root@localhost:3306/study_room_reservation
JWT_SECRET=dev-secret
PUBLIC_DIR=snack-backend/public
```

---

## 四、常见问题

| 问题 | 原因 | 处理 |
|------|------|------|
| 手机「网络错误」 | 前端仍指向 localhost | 设置 Netlify `VITE_API_URL` 并重新部署 |
| Railway 构建失败 | 缺 Cargo.lock | 确保仓库含 `Cargo.lock` 和 `src/` |
| 登录 401/数据库错误 | 未导入 SQL | 执行 `study_room_reservation.sql` |
| 商品图不显示 | 图片路径 | 确认 Railway 镜像含 `public/`，访问 `/api/products` 看 picture 字段 |

---

## 五、推送代码触发更新

```bash
git add .
git commit -m "部署配置：API 环境变量、Docker、Railway"
git push origin master
git push github master   # 若使用 GitHub 连 Netlify/Railway
```

Railway 与 Netlify 会在 push 后自动重新构建（Netlify 需已配置 `VITE_API_URL`）。
