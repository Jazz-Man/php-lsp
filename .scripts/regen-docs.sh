#!/bin/bash
# Регенерація всієї документації
set -e

echo "📚 Regenerating documentation..."
cargo doc --no-deps
cargo doc-md

echo "✅ Documentation updated!"
echo ""
echo "📁 Index: target/doc-md/index.md"
echo ""
echo "Available crates:"
ls -1 target/doc-md/ | grep -v "index.md" | head -20
