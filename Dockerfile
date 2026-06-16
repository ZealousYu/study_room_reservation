# syntax=docker/dockerfile:1

FROM rust:1-bookworm AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/target/release/study_room_backend .
COPY snack-backend/public ./public
ENV PUBLIC_DIR=public
ENV SERVER_HOST=0.0.0.0
EXPOSE 8080
CMD ["./study_room_backend"]
