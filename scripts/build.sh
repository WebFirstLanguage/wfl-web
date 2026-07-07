#!/usr/bin/env bash
# Build the WFL website. Renders the Scribe templates in templates/ into
# static HTML in public/ using build.wfl.
#
# Usage:  scripts/build.sh [path/to/wfl]
# If no WFL binary path is given, `wfl` on your PATH is used.
set -euo pipefail

# Resolve repo root (this script lives in scripts/).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WFL="${1:-wfl}"

echo "Building WFL website with: $WFL"
# Scribe's static checker emits non-fatal "could not infer type" notes on
# stderr for calls into the engine; the program still runs and exits 0.
"$WFL" build.wfl

echo
echo "Output in: $ROOT/public"
