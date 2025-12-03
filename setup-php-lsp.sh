#!/bin/bash
# setup-php-lsp.sh
# Повне налаштування PHP LSP проекту для Zed
# spec-kit-plus + Claude (планування) + Qwen (імплементація) + auto-docs

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       PHP LSP for Zed - Project Setup                        ${NC}"
echo -e "${BLUE}       Claude (planning) + Qwen (implementation)              ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================
# 1. Перевірка залежностей
# ============================================================
echo -e "${BLUE}[1/8] Checking prerequisites...${NC}"

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}  ✗ $1 not found${NC}"
        return 1
    else
        echo -e "  ${GREEN}✓${NC} $1"
        return 0
    fi
}

MISSING=0
check_command "cargo" || MISSING=1
check_command "rustup" || MISSING=1
check_command "git" || MISSING=1

if [ $MISSING -eq 1 ]; then
    echo -e "${RED}Please install missing dependencies first.${NC}"
    exit 1
fi

# Rust nightly (для cargo-doc-md)
if ! rustup run nightly rustc --version &> /dev/null; then
    echo -e "  ${YELLOW}Installing Rust nightly...${NC}"
    rustup install nightly
fi
echo -e "  ${GREEN}✓${NC} rust nightly"

# WASM target (для Zed extension)
if ! rustup target list | grep -q "wasm32-wasip2 (installed)"; then
    echo -e "  ${YELLOW}Adding wasm32-wasip2 target...${NC}"
    rustup target add wasm32-wasip2
fi
echo -e "  ${GREEN}✓${NC} wasm32-wasip2 target"

# cargo-doc-md
if ! command -v cargo-doc-md &> /dev/null; then
    echo -e "  ${YELLOW}Installing cargo-doc-md...${NC}"
    cargo install cargo-doc-md
fi
echo -e "  ${GREEN}✓${NC} cargo-doc-md"

# specifyplus
if ! command -v specifyplus &> /dev/null && ! command -v sp &> /dev/null; then
    echo -e "  ${YELLOW}Installing spec-kit-plus...${NC}"
    pip install specifyplus
fi
echo -e "  ${GREEN}✓${NC} specifyplus"

echo ""

# ============================================================
# 2. Git ініціалізація
# ============================================================
echo -e "${BLUE}[2/8] Initializing Git repository...${NC}"
if [ ! -d ".git" ]; then
    git init
    echo -e "  ${GREEN}✓${NC} Git initialized"
else
    echo -e "  ${GREEN}✓${NC} Git already initialized"
fi
echo ""

# ============================================================
# 3. Структура проекту (workspace з двох крейтів)
# ============================================================
echo -e "${BLUE}[3/8] Creating project structure...${NC}"

# Workspace Cargo.toml
cat > Cargo.toml << 'EOF'
[workspace]
resolver = "2"
members = [
    "crates/php-lsp",
    "crates/zed-php-lsp",
]

[workspace.package]
version = "0.1.0"
edition = "2021"
license = "MIT"
EOF
echo -e "  ${GREEN}✓${NC} Workspace Cargo.toml"

# PHP LSP crate
mkdir -p crates/php-lsp/src
cat > crates/php-lsp/Cargo.toml << 'EOF'
[package]
name = "php-lsp"
version.workspace = true
edition.workspace = true

[dependencies]
async-lsp = { version = "0.2.2", features = ["tokio"] }
tree-sitter = "0.25.10"
tree-sitter-php = "0.24.2"
tokio = { version = "1", features = ["full"] }
lsp-types = "0.97"
ropey = "1.6"
dashmap = "6"
thiserror = "2"
anyhow = "1"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
url = "2"
EOF

cat > crates/php-lsp/src/main.rs << 'EOF'
fn main() {
    println!("PHP LSP Server - Work in Progress");
    println!("Run with --stdio for LSP mode");
}
EOF

cat > crates/php-lsp/src/lib.rs << 'EOF'
//! PHP Language Server Protocol implementation
//!
//! A custom LSP server for PHP with WordPress hooks support.

pub mod server;

pub use server::run_server;
EOF

mkdir -p crates/php-lsp/src/server
cat > crates/php-lsp/src/server/mod.rs << 'EOF'
//! LSP Server implementation

/// Run the LSP server (placeholder)
pub fn run_server() {
    todo!("Implement LSP server")
}
EOF
echo -e "  ${GREEN}✓${NC} crates/php-lsp/"

# Zed Extension crate
mkdir -p crates/zed-php-lsp/src
cat > crates/zed-php-lsp/Cargo.toml << 'EOF'
[package]
name = "zed-php-lsp"
version.workspace = true
edition.workspace = true

[lib]
crate-type = ["cdylib"]

[dependencies]
zed_extension_api = "0.7"
EOF

cat > crates/zed-php-lsp/src/lib.rs << 'EOF'
//! Zed extension for PHP LSP

use zed_extension_api::{self as zed, Result};

struct PhpLspExtension {
    cached_binary_path: Option<String>,
}

impl zed::Extension for PhpLspExtension {
    fn new() -> Self {
        Self { cached_binary_path: None }
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let binary_path = worktree
            .which("php-lsp")
            .ok_or_else(|| "php-lsp not found in PATH".to_string())?;

        Ok(zed::Command {
            command: binary_path,
            args: vec!["--stdio".to_string()],
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(PhpLspExtension);
EOF

cat > crates/zed-php-lsp/extension.toml << 'EOF'
id = "php-lsp"
name = "PHP LSP (Custom)"
version = "0.1.0"
schema_version = 1
authors = ["Your Name <you@example.com>"]
description = "Custom PHP language server with WordPress hooks support"

[language_servers.php-lsp]
name = "PHP LSP"
languages = ["PHP"]
EOF
echo -e "  ${GREEN}✓${NC} crates/zed-php-lsp/"

echo ""

# ============================================================
# 4. Helper scripts
# ============================================================
echo -e "${BLUE}[4/8] Creating helper scripts...${NC}"

mkdir -p .scripts

cat > .scripts/add-dep.sh << 'ADDEOF'
#!/bin/bash
set -e
if [ -z "$1" ]; then
    echo "Usage: .scripts/add-dep.sh <crate> [options]"
    exit 1
fi
CRATE=$1; shift
echo "📦 Adding: $CRATE $@"
cd crates/php-lsp && cargo add "$CRATE" "$@" && cd ../..
.scripts/regen-docs.sh
cargo info "$CRATE" 2>/dev/null || true
ADDEOF
chmod +x .scripts/add-dep.sh

cat > .scripts/regen-docs.sh << 'REGENEOF'
#!/bin/bash
set -e
echo "📚 Generating documentation..."
cargo doc --workspace --no-deps 2>/dev/null || cargo doc --workspace
cargo doc-md 2>/dev/null || cargo +nightly doc-md 2>/dev/null || echo "⚠️ MD docs failed"
[ -d "target/doc-md" ] && echo "✅ Done: target/doc-md/index.md"
REGENEOF
chmod +x .scripts/regen-docs.sh

cat > .scripts/build-extension.sh << 'BUILDEOF'
#!/bin/bash
set -e
echo "🔨 Building Zed extension..."
cd crates/zed-php-lsp
cargo build --release --target wasm32-wasip2
echo "✅ Built! Install via: zed: install dev extension → $(pwd)"
BUILDEOF
chmod +x .scripts/build-extension.sh

cat > .scripts/install-lsp.sh << 'INSTALLEOF'
#!/bin/bash
set -e
echo "🔨 Building php-lsp..."
cargo build --release -p php-lsp
mkdir -p "$HOME/.local/bin"
cp target/release/php-lsp "$HOME/.local/bin/"
echo "✅ Installed: ~/.local/bin/php-lsp"
INSTALLEOF
chmod +x .scripts/install-lsp.sh

echo -e "  ${GREEN}✓${NC} Helper scripts created"
echo ""

# ============================================================
# 5. Генерація документації
# ============================================================
echo -e "${BLUE}[5/8] Generating initial documentation...${NC}"
cargo build --workspace 2>/dev/null || true
.scripts/regen-docs.sh 2>/dev/null || echo -e "  ${YELLOW}⚠${NC} Docs will generate after first successful build"
echo ""

# ============================================================
# 6. spec-kit-plus
# ============================================================
echo -e "${BLUE}[6/8] Initializing spec-kit-plus...${NC}"

if [ ! -d ".claude" ]; then
    specifyplus init --here --ai claude --force 2>/dev/null || sp init --here --ai claude --force 2>/dev/null || true
fi
echo -e "  ${GREEN}✓${NC} Claude"

if [ ! -d ".qwen" ]; then
    specifyplus init --here --ai qwen --force 2>/dev/null || sp init --here --ai qwen --force 2>/dev/null || true
fi
echo -e "  ${GREEN}✓${NC} Qwen"
echo ""

# ============================================================
# 7. .gitignore
# ============================================================
echo -e "${BLUE}[7/8] Creating .gitignore...${NC}"
cat > .gitignore << 'EOF'
/target/
.idea/
.vscode/
*.swp
.claude/settings.json
.qwen/settings.json
.DS_Store
*.log
EOF
echo -e "  ${GREEN}✓${NC} .gitignore"
echo ""

# ============================================================
# 8. Initial commit
# ============================================================
echo -e "${BLUE}[8/8] Creating initial commit...${NC}"
git add -A
git commit -m "chore: initial project setup" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Done"
echo ""

# ============================================================
# Фінальний вивід
# ============================================================
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Setup complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Structure:"
echo "  crates/php-lsp/        <- LSP server"
echo "  crates/zed-php-lsp/    <- Zed extension"
echo "  .specify/              <- Specifications"
echo "  target/doc-md/         <- Documentation for AI"
echo ""
echo "Scripts:"
echo "  .scripts/add-dep.sh <crate>     Add dependency + regen docs"
echo "  .scripts/regen-docs.sh          Regenerate documentation"
echo "  .scripts/build-extension.sh     Build Zed extension"
echo "  .scripts/install-lsp.sh         Install LSP binary"
echo ""
echo -e "${YELLOW}Workflow:${NC}"
echo "  1. claude → /sp.constitution"
echo "  2. claude → /sp.specify → /sp.plan → /sp.tasks"
echo "  3. qwen   → /sp.implement"
echo "  4. Repeat 2-3 for each feature"
