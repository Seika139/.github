#!/bin/bash

#MISE description="terraformでgithubリポジトリのブランチ保護ルールを設定する"
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

read -rp "上記の内容で適用しますか？ (y/n): " confirm
if ! [[ "$confirm" =~ ^[Yy]$ ]]; then
  log_yellow "適用を中止しました。"
  exit 0
fi

dotenvx run -- terraform -chdir=terraform/github apply -auto-approve
