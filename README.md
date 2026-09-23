<h1 align="center">SvnGo</h1>

<p align="center">
  <b>轻量 SVN 图形化客户端 · 内置 SVN 客户端，零依赖</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-blue" alt="Platform">
  <img src="https://img.shields.io/badge/size-10MB-brightgreen" alt="Size">
  <img src="https://img.shields.io/badge/React-19-61DAFB" alt="React 19">
  <img src="https://img.shields.io/badge/Tauri-v2-FFC131" alt="Tauri v2">
  <img src="https://img.shields.io/github/v/release/Brid9e/svn-go" alt="Latest Release">
</p>

---

## ✨ 功能一览

| 功能 | 说明 |
|------|------|
| 远程仓库浏览 | 树形结构浏览 SVN 目录，支持按日期排序、按扩展名筛选 |
| 本地目录浏览 | 浏览本地文件系统，实时显示 SVN 状态（M/A/D/?/C/!） |
| 文件替换提交 | 选择本地文件/目录，直接上传替换远程 SVN 内容 |
| 文件重命名 | 右键远程文件/目录进行重命名 |
| 新建目录 | 右键远程目录快速创建子目录 |
| 提交管理 | 工作副本更新、添加、删除、还原、清理 |
| 提交历史 | 查看文件/目录的 SVN log 时间线 |
| 文件差异 | 查看文件最新版本的 Diff |

---

## 🖥 预览

![SvnGo 截图](public/example.png)

---

## 🛠 技术栈

| 层面 | 技术 |
|------|------|
| 前端 | React 19 + TypeScript + Vite |
| 桌面框架 | Tauri v2 |
| 后端 | Rust（通过 Tauri command 调用 SVN CLI） |
| 版本控制 | 内置静态 SVN 客户端（Apache Subversion，随包分发，无需系统安装） |

---

## 📦 安装

> **注意**: SvnGo 当前仅支持 **macOS**（ARM64）。

从 [Releases](https://github.com/Brid9e/svn-go/releases) 下载 `.dmg` 安装包（约 **10MB**），打开即可使用。

**零依赖**: 安装包已内置静态链接的 SVN 客户端（Apache Subversion 1.14.x），**无需**在系统安装 svn。

---

## 🔧 开发

```bash
# 安装依赖
pnpm install

# 启动开发模式
pnpm tauri dev

# 构建生产版本
pnpm tauri build
```

### 环境要求

- Node.js 20+
- pnpm
- Rust toolchain
- （可选）系统 SVN 命令行客户端——仅用于开发调试；发布包已内置静态 svn，用户无需安装

> 内置 svn 客户端构建脚本：`src-tauri/scripts/build-static-svn.sh`（需 Homebrew: apr apr-util serf sqlite openssl@3 zlib）。产物 `src-tauri/resources/svn/svn` 随 `bundle.resources` 打进安装包，运行时优先加载。

---

<p align="center">
  Made with ❤️
</p>
