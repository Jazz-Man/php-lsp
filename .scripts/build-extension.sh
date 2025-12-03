#!/bin/bash
set -e
echo "🔨 Building Zed extension..."
cd crates/zed-php-lsp
cargo build --release --target wasm32-wasip2
echo "✅ Built! Install via: zed: install dev extension → $(pwd)"
