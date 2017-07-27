FROM lawliet89/docker-rust:1.19.0 as builder

ARG ARCHITECTURE=x86_64-unknown-linux-musl

WORKDIR /app/src
COPY Cargo.toml Cargo.lock ./
RUN cargo fetch --locked -v

COPY ./ ./
RUN cargo build --release --target "${ARCHITECTURE}" -v --frozen

# Runtime Image

FROM alpine:3.6
ARG ARCHITECTURE=x86_64-unknown-linux-musl

ENV OPENSSL_DIR=/openssl \
    OPENSSL_INCLUDE_DIR=/openssl/include \
    OPENSSL_LIB_DIR=/openssl/lib
COPY --from=builder /openssl /openssl

RUN set -x \
    && apk add --update ca-certificates \
    && update-ca-certificates

WORKDIR /app
COPY --from=builder /app/src/target/${ARCHITECTURE}/release/rcanary .
CMD ["/app/rcanary"]
