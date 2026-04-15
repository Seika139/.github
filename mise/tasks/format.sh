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

if command -v rumdl >/dev/null 2>&1; then
  log_cyan "Running rumdl check --fix..."
  # 明示パスを渡すと --respect-gitignore が効かないので引数なしで実行する
  rumdl check --fix
elif command -v markdownlint-cli2 >/dev/null 2>&1; then
  log_cyan "rumdl not found; falling back to markdownlint-cli2 --fix..."
  markdownlint-cli2 --fix
else
  log_red "neither rumdl nor markdownlint-cli2 is installed; skipping markdown formatting."
fi

if command -v terraform >/dev/null 2>&1; then
  log_cyan "Running terraform fmt..."
  terraform fmt -recursive
else
  log_red "terraform is not installed; skipping terraform formatting."
fi
