#!/usr/bin/env bash
# Serve the WFL website dynamically — WFL renders each page live on every
# request (see serve.wfl). Static assets stream from public/assets.
#
# Usage:  scripts/serve.sh [path/to/wfl]
# If no WFL binary path is given, `wfl` on your PATH is used.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WFL="${1:-wfl}"

echo "Starting the live WFL server on http://127.0.0.1:8080 (Ctrl+C to stop)"
exec "$WFL" serve.wfl
