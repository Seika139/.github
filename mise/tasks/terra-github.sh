#!/bin/bash

#MISE description="terraformでgithubリポジトリのブランチ保護ルールを設定する"
#MISE shell="bash -c"
#MISE quiet=false
#MISE depends=["dotenvx"]

dotenvx run -- terraform -chdir=terraform/github apply -auto-approve
