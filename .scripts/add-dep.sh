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
