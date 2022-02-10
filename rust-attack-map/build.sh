#!/bin/sh
#rustup target add x86_64-unknown-linux-gnu
#cargo build -p lambda_runtime --example basic --release --target x86_64-unknown-linux-gnu
RUST_TARGET="x86_64-unknown-linux-gnu" # corresponding with the above, set this to aarch64 or x86_64 -unknown-linux-gnu for ARM or x86 functions.
LAMBDA_ARCH="linux/amd64" # set this to either linux/arm64 for ARM functions, or linux/amd64 for x86 functions.
# RUST_VERSION="latest" # Set this to a specific version of rust you want to compile for, or to latest if you want the latest stable version.
docker build -f Dockerfile -t rust-aws-build/1.0 .
docker tag rust-aws-build/1.0 rust-aws-build/1.0
docker run \
    --platform ${LAMBDA_ARCH} \
    --rm --user "$(id -u)":"$(id -g)" \
    -v "${PWD}":/usr/src/myapp -w /usr/src/myapp rust-aws-build/1.0 \
    cargo build --verbose -p rust-attack-map --release --target ${RUST_TARGET}
mv ./target/${RUST_TARGET}/release/rust-attack-map ./target/${RUST_TARGET}/release/bootstrap
cd ./target/${RUST_TARGET}/release
zip -j lambda.zip bootstrap