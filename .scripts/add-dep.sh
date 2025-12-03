#!/bin/bash
# Wrapper для cargo add з автоматичною генерацією документації
set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/add-dep.sh <crate-name> [cargo add options]"
    exit 1
fi

echo "📦 Adding dependency: $@"
cargo add "$@"

echo "📚 Regenerating documentation..."
cargo doc --no-deps
cargo doc-md

echo "✅ Done! Documentation updated at target/doc-md/"
echo ""
echo "📖 Crate info:"
cargo info "$1" 2>/dev/null || echo "Run: cargo info $1"
