#!/bin/bash

#MISE description="uvを利用して仮想環境を作成します"
#MISE shell="bash -c"
#MISE quiet=true
#MISE hide=true
#MISE depends = ["chmod-scripts"]

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

project_root="${MISE_CONFIG_ROOT:-$PWD}"
venv_dir="${project_root}/.venv"
python_version="$(get_python_version)"
echo "python_version: $python_version"

venv_python=""
if [ -f "$venv_dir/bin/python" ]; then
  venv_python="$venv_dir/bin/python"
elif [ -f "$venv_dir/Scripts/python.exe" ]; then
  venv_python="$venv_dir/Scripts/python.exe"
fi

current_version=""
if [ -n "$venv_python" ]; then
  current_version="$("$venv_python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
fi

needs_recreate=false
if [ ! -d "$venv_dir" ] || [ -z "$venv_python" ]; then
  needs_recreate=true
elif [ "$current_version" != "$python_version" ]; then
  needs_recreate=true
fi

if [ "$needs_recreate" = true ]; then
  echo "Creating .venv with Python $python_version ..."
  mkdir -p "$venv_dir"
  chmod -R +w "$venv_dir" 2>/dev/null || true
  find "$venv_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
  uv venv --python "$python_version" --allow-existing "$venv_dir"
else
  echo "Use existing .venv"
fi
