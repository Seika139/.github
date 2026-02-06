#!/bin/bash

#MISE description="terraformでgithubリポジトリのブランチ保護ルールを設定する"
#MISE shell="bash -c"
#MISE quiet=false
#MISE depends=["dotenvx"]

REPO_FULLNAME=$(git remote get-url origin | sed -e 's/.*github.com[:\/]\(.*\)\.git/\1/')
DOTENV_KEY=$(grep "DOTENV_PRIVATE_KEY=" .env.keys | cut -d'=' -f2)

if ! dotenvx run -- sh -c "
  TF_VAR_DOTENV_PRIVATE_KEY='${DOTENV_KEY}' \
  TF_VAR_github_repository_full_name='${REPO_FULLNAME}' \
  terraform -chdir=terraform/github plan
"; then
  echo "terraform plan の実行に失敗しました。"
  exit 1
fi

read -rp "上記の内容で適用しますか？ (y/n): " confirm
if ! [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "適用を中止しました。"
  exit 0
fi

dotenvx run -- sh -c "
  TF_VAR_DOTENV_PRIVATE_KEY='${DOTENV_KEY}' \
  TF_VAR_github_repository_full_name='${REPO_FULLNAME}' \
  terraform -chdir=terraform/github apply -auto-approve
"
