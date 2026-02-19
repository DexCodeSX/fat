FROM rust:latest AS builder
WORKDIR /app
COPY . .
RUN rustup default nightly
RUN cargo build --release --bin medal
RUN strip target/release/medal

FROM debian:12-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/medal /bin/medal
EXPOSE 3000
ENTRYPOINT ["/bin/medal"]
CMD ["serve", "--port", "3000"]
