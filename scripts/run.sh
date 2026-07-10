#!/usr/bin/env bash
# Run wfl-web (powered by the Scriptorium CMS engine) from the repo root.
# Template + asset paths resolve relative to the working directory, so always
# launch from the repository root.
set -euo pipefail
cd "$(dirname "$0")/.."
exec wfl main.wfl
