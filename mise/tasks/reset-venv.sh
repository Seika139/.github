#!/bin/bash

#MISE description="仮想環境をリセットします"
#MISE shell="bash -c"
#MISE quiet=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

project_root="${MISE_CONFIG_ROOT:-$PWD}"
venv_dir="${project_root}/.venv"
python_version="$(get_python_version)"

echo "Resetting .venv ..."
mkdir -p "$venv_dir"
chmod -R +w "$venv_dir" 2>/dev/null || true
find "$venv_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
uv venv --python "$python_version" --allow-existing "$venv_dir"
echo "done. Run 'mise run init' to sync dependencies."
