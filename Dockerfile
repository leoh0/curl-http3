# function curl() {
#   docker run --rm \
#     --name curl \
#     leoh0/curl "$@"
# }
# curl --http3 https://www.facebook.com/ -v -s -o /dev/null

FROM alpine:3.11 as base

RUN apk add --update \
    git \
    gcc \
    file \
    make \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    cmake \
    build-base \
    perl \
    go \
    linux-headers \
    cargo \
    libtool \
    autoconf \
    automake \
    pkgconfig \
    ca-certificates \
  && rm -rf /var/cache/apk/* \ 
  && update-ca-certificates

WORKDIR /app

ARG QUICHE_VERSION=0.2.0
ARG CURL_VERSION=curl-7_68_0

RUN git clone --branch ${QUICHE_VERSION} \
  --recursive https://github.com/cloudflare/quiche.git

RUN git clone --branch ${CURL_VERSION} \
  https://github.com/curl/curl.git

# Build BoringSSL
RUN cd /app/quiche/deps/boringssl/ \
  && mkdir -p build \
  && cd /app/quiche/deps/boringssl/build/ \
  && cmake -DCMAKE_POSITION_INDEPENDENT_CODE=on .. \
  && make \
  && cd /app/quiche/deps/boringssl/ \
  && mkdir -p .openssl/lib \
  && cp build/crypto/libcrypto.a build/ssl/libssl.a .openssl/lib \
  && cp -R include/ .openssl/

# Build quiche
RUN cd /app/quiche/ \
  && QUICHE_BSSL_PATH=$PWD/deps/boringssl \
    cargo build \
    --release \
    --features pkg-config-meta

# Build curl
RUN cd /app/curl \
  && ./buildconf \
  && ./configure \
    LDFLAGS="-Wl,-rpath,/app/quiche/target/release" \
    --with-ssl=/app/quiche/deps/boringssl/.openssl \
    --with-quiche=/app/quiche/target/release \
    --disable-shared \
    --enable-alt-svc \
  && make curl_LDFLAGS=-all-static \
  && strip /app/curl/src/curl

FROM scratch

COPY --from=base /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=base /app/curl/src/curl /curl

ENTRYPOINT [ "/curl" ]
