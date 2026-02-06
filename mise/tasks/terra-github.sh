#!/bin/bash

#MISE description="terraformでgithubリポジトリのブランチ保護ルールを設定する"
#MISE shell="bash -c"
#MISE quiet=false
#MISE depends=["dotenvx"]

dotenvx run -- terraform -chdir=terraform/github plan

read -rp "上記の内容で適用しますか？ (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "適用を中止しました。"
  exit 0
fi

dotenvx run -- terraform -chdir=terraform/github apply -auto-approve
