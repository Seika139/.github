#!/bin/bash

#MISE description="terraform planを実行する"
#MISE shell="bash -c"
#MISE quiet=false
#MISE depends=["dotenvx"]

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

TF_VAR_DOTENV_PRIVATE_KEY=$(grep "DOTENV_PRIVATE_KEY=" .env.keys | cut -d'=' -f2-)
export TF_VAR_DOTENV_PRIVATE_KEY

if ! dotenvx run -- terraform -chdir=terraform/github plan; then
  log_red "terraform plan の実行に失敗しました。"
  exit 1
fi
