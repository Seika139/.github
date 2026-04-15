#!/bin/bash

#MISE description="コードの静的解析とテストを実行します"
#MISE shell="bash -c"
#MISE quiet=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

log_cyan "Running ruff check..."
uv run ruff check .

log_cyan "Running mypy..."
uv run mypy

log_cyan "Running ty check..."
uv run ty check .

log_cyan "Running vulture..."
targets=()
if [ -d "src" ]; then targets+=("src"); fi
if [ -d "tests" ]; then targets+=("tests"); fi
if [ ${#targets[@]} -eq 0 ]; then
  targets+=(".")
fi
whitelist_paths=""
if [ -f vulture/whitelists/local.py ]; then
  whitelist_paths="vulture/whitelists/local.py"
fi
uv run vulture --min-confidence 90 --exclude alembic "${targets[@]}" $whitelist_paths

if [ -d "tests" ]; then
  log_cyan "Running pytest..."
  uv run pytest tests/
else
  log_yellow "tests/ directory not found; skipping pytest."
fi

if command -v rumdl >/dev/null 2>&1; then
  log_cyan "Running rumdl check..."
  rumdl check .
else
  log_red "rumdl is not installed; skipping markdown linting."
fi

log_cyan "Running yamllint..."
uv run yamllint . # .yamllint.yml は自動的に読み込まれる

if command -v shellcheck >/dev/null 2>&1; then
  log_cyan "Running shellcheck..."
  shellcheck_files=()
  while IFS= read -r -d '' file; do
    shellcheck_files+=("$file")
  done < <(find . -type f \( -name "*.sh" -o -name "*.bash" \) -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./.git/*" -print0)
  if [ "${shellcheck_files[0]+_}" ]; then
    shellcheck -x -P SCRIPTDIR "${shellcheck_files[@]}"
  else
    log_cyan "No shell scripts found; skipping shellcheck."
  fi
else
  log_red "shellcheck is not installed; skipping shell script linting."
fi

log_cyan "Running terraform fmt check..."
if command -v terraform >/dev/null 2>&1; then
  terraform fmt -check -recursive
else
  log_red "terraform is not installed; skipping terraform fmt check."
fi
