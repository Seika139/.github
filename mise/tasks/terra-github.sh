#!/bin/bash

#MISE description="terraformでgithubリポジトリのブランチ保護ルールを設定する"
#MISE shell="bash -c"
#MISE quiet=false
#MISE depends=["dotenvx"]

TF_VAR_DOTENV_PRIVATE_KEY=$(grep "DOTENV_PRIVATE_KEY=" .env.keys | cut -d'=' -f2)
export TF_VAR_DOTENV_PRIVATE_KEY

if ! dotenvx run -- terraform -chdir=terraform/github plan; then
  echo "terraform plan の実行に失敗しました。"
  echo "適用を中止しました。"
  exit 0
fi

read -rp "上記の内容で適用しますか？ (y/n): " confirm
if ! [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "適用を中止しました。"
  exit 0
fi

dotenvx run -- terraform -chdir=terraform/github apply -auto-approve
