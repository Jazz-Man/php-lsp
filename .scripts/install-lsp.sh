#!/bin/bash
set -e
echo "🔨 Building php-lsp..."
cargo build --release -p php-lsp
mkdir -p "$HOME/.local/bin"
cp target/release/php-lsp "$HOME/.local/bin/"
echo "✅ Installed: ~/.local/bin/php-lsp"
