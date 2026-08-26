#!/usr/bin/env bash
# 构建静态链接的 svn 客户端（方案 A：应用内置，用户无需安装 svn 客户端）
#
# 用法: bash scripts/build-static-svn.sh [subversion 版本，默认 1.14.5]
# 产物: src-tauri/resources/svn/svn（已 ad-hoc 签名，随安装包分发）
#
# 前置依赖（Homebrew）: apr apr-util apache-serf sqlite openssl@3 zlib lz4 utf8proc expat
#   brew install apr apr-util apache-serf sqlite openssl@3 zlib lz4 utf8proc expat
#   （注意：是 apache-serf，不是 serf —— serf 是 HashiCorp 的工具，别装错）
#
# 说明: macOS 的 libtool 不支持 -all-static（--enable-all-static 不会真正静态化），
#       所以编译完成后用 -Wl,-force_load 把第三方静态库强制嵌入 svn，
#       再用 -Wl,-dead_strip_dylibs 剥掉未引用的 dylib，得到只依赖系统库的单文件。
set -euo pipefail

VERSION="${1:-1.14.5}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                # src-tauri
OUT_DIR="$ROOT/resources/svn"
BUILD_DIR="$ROOT/target/svn-static-build"
SRC_URL="https://dlcdn.apache.org/subversion/subversion-${VERSION}.tar.bz2"

if [ "$(uname -m)" = "arm64" ]; then
  HOMEBREW_PREFIX="/opt/homebrew"
else
  HOMEBREW_PREFIX="/usr/local"
fi

# 依赖检查
for dep in apr apr-util apache-serf sqlite openssl@3 zlib lz4 utf8proc expat; do
  if [ ! -d "$HOMEBREW_PREFIX/opt/$dep" ]; then
    echo "缺少依赖 $dep，请先执行: brew install $dep" >&2
    exit 1
  fi
done

# 重链接时强制静态嵌入的第三方库（macOS 上全静态的另一种实现方式）
STATIC_LDFLAGS="\
-Wl,-force_load,$HOMEBREW_PREFIX/opt/apr/lib/libapr-1.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/apr-util/lib/libaprutil-1.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/apache-serf/lib/libserf-1.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/sqlite/lib/libsqlite3.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/zlib/lib/libz.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/lz4/lib/liblz4.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/utf8proc/lib/libutf8proc.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/expat/lib/libexpat.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/openssl@3/lib/libssl.a \
-Wl,-force_load,$HOMEBREW_PREFIX/opt/openssl@3/lib/libcrypto.a \
-framework Kerberos -Wl,-dead_strip_dylibs"

mkdir -p "$OUT_DIR" "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d "subversion-$VERSION" ]; then
  echo "==> 下载 subversion-$VERSION"
  curl -fL "$SRC_URL" -o "subversion-$VERSION.tar.bz2"
  tar xjf "subversion-$VERSION.tar.bz2"
fi

cd "subversion-$VERSION"

if [ ! -f Makefile ]; then
  echo "==> configure（--enable-all-static）"
  ./configure \
    --enable-all-static \
    --with-apr="$HOMEBREW_PREFIX/opt/apr" \
    --with-apr-util="$HOMEBREW_PREFIX/opt/apr-util" \
    --with-serf="$HOMEBREW_PREFIX/opt/apache-serf" \
    --with-sqlite="$HOMEBREW_PREFIX/opt/sqlite" \
    --with-zlib="$HOMEBREW_PREFIX/opt/zlib" \
    --with-lz4="$HOMEBREW_PREFIX/opt/lz4" \
    --with-utf8proc="$HOMEBREW_PREFIX/opt/utf8proc"
fi

echo "==> make -j$(sysctl -n hw.ncpu)"
make -j"$(sysctl -n hw.ncpu)"

echo "==> 重链接 svn（force_load 静态嵌入第三方库）"
rm -f subversion/svn/svn subversion/svn/.libs/svn
make LDFLAGS="$STATIC_LDFLAGS" subversion/svn/svn

echo "==> 复制并签名产物"
cp subversion/svn/svn "$OUT_DIR/svn"
codesign -s - "$OUT_DIR/svn" || true

echo "==> 完成: $OUT_DIR/svn"
file "$OUT_DIR/svn"
otool -L "$OUT_DIR/svn" | grep -c "/opt/homebrew" || true
"$OUT_DIR/svn" --version --quiet
