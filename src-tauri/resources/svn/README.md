# 内置 SVN 客户端

本目录存放随应用打包的**静态链接 svn 可执行文件**（方案 A：用户无需安装 SVN 客户端）。

- `svn` — 静态链接的 svn（macOS arm64，Apache Subversion 1.14.x），由构建脚本生成，**不入库**（见根目录 .gitignore）。
- 构建方式：`bash src-tauri/scripts/build-static-svn.sh`（需 Homebrew: apr apr-util apache-serf sqlite openssl@3 zlib lz4 utf8proc）。

运行时 `lib.rs` 的 `resolve_svn_path()` 会优先使用 `resource_dir()/svn/svn`，找不到才回退系统 svn。
