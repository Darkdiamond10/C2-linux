#!/bin/bash
set -e

PREFIX=$HOME/musl
export CC="$PREFIX/bin/musl-gcc -static"
export CFLAGS="-fPIC -DOPENSSL_NO_SECURE_MEMORY"
BUILD_DIR=$(mktemp -d)
echo "Building in $BUILD_DIR"

cd "$BUILD_DIR"

# Build OpenSSL
if [ ! -f "$PREFIX/lib/libssl.a" ]; then
    echo "Building OpenSSL..."
    curl -L -O https://www.openssl.org/source/openssl-1.1.1w.tar.gz
    tar xzf openssl-1.1.1w.tar.gz
    cd openssl-1.1.1w
    ./config --prefix=$PREFIX --openssldir=$PREFIX/ssl no-shared no-zlib no-async no-tests no-engine $CFLAGS
    make -j$(nproc)
    make install_sw
    cd ..
fi

# Build curl
if [ ! -f "$PREFIX/lib/libcurl.a" ]; then
    echo "Building curl..."
    curl -L -O https://curl.se/download/curl-8.5.0.tar.gz
    tar xzf curl-8.5.0.tar.gz
    cd curl-8.5.0
    ./configure --prefix=$PREFIX --disable-shared --enable-static \
                --with-openssl=$PREFIX --disable-ldap --disable-ldaps \
                --disable-rtsp --disable-dict --disable-telnet --disable-tftp \
                --disable-pop3 --disable-imap --disable-smtp --disable-gopher \
                --disable-manual --disable-libcurl-option --without-zlib
    make -j$(nproc)
    make install
    cd ..
fi

echo "Dependencies built successfully."
rm -rf "$BUILD_DIR"
