#!/bin/bash

#MISE description="コードのフォーマットを実行します"
#MISE shell="bash -c"
#MISE quiet=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

log_cyan "Running ruff format..."
uv run ruff format .

log_cyan "Running ruff check with --fix..."
uv run ruff check . --fix

if command -v markdownlint-cli2 >/dev/null 2>&1; then
  log_cyan "Running markdownlint fix..."
  if [ -e .markdownlint-cli2.jsonc ]; then
    markdownlint-cli2 --config .markdownlint-cli2.jsonc --fix
  else
    markdownlint-cli2 --fix .
  fi
else
  log_red "markdownlint-cli2 is not installed; skipping markdown formatting."
fi

if command -v terraform >/dev/null 2>&1; then
  log_cyan "Running terraform fmt..."
  terraform fmt -recursive
else
  log_red "terraform is not installed; skipping terraform formatting."
fi
