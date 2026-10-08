---
name: terraform-operations
description: このリポジトリの Terraform 設定・state の調査や変更、init/plan/apply/import、HCP Terraform の設定や端末接続を行うときに使います。Terraform 作業に着手する前に必ず読み、state と適用内容の安全確認に従ってください。
---

# Terraform Operations

## HCP workspace と認証

- Terraform state は HCP Terraform の `seika139-github/github-repositories` workspace に保存します。workspace の Execution Mode は `Local` にし、各 PC/VPS 上の Terraform CLI で plan/apply を実行します。
- HCP Terraform が共有 state と state lock を管理します。state lock の待機やエラーを尊重し、lock を迂回したり state を手作業で書き換えたりしません。
- 各実行環境で `terraform login` を行います。GitHub provider の認証情報と dotenvx secrets は各 PC/VPS 内で管理し、HCP workspace variables に置きません。Local mode では workspace variables は Terraform CLI に適用されません。

## 初期化と state

- 初回の state 移行と追加端末の接続手順は [README.md の HCP Terraform 手順](../../../README.md) を正本として実行します。手順を短縮したり、state の移行元や移行先を推測したりしません。
- state 移行では、移行元 state を最後に操作した Terraform CLI と同じバージョンを使います。移行元の state をバックアップし、同じ workspace に対する他の Terraform 操作を止める手順も README に従います。
- 既存の local state が残る端末を HCP workspace に接続するときは、README の指示に従い `terraform/github/terraform.tfstate` と関連する backup/workspace files、および `terraform/github/.terraform/terraform.tfstate` backend metadata を権限を限定した場所へリポジトリ外退避してから `mise run init` を行います。これにより古い state を共有 workspace へ誤って移行しません。
- 通常の初期化には `mise run init` を使い、Terraform の `init -reconfigure` は使いません。この HCP cloud 設定では通常の `terraform init` を使います。初回の state 移行では README の手順に従います。

## plan と apply

- 通常の操作には `mise run init`、`mise run terra-plan`、`mise run terra-apply` を使います。これらのタスクは各端末の dotenvx/GitHub provider 認証情報を使います。
- plan の内容を確認し、意図しない大量の create/destroy があれば停止して原因を調べます。
- 適用時は `mise run terra-apply` が表示する plan を確認し、その同じ `terraform apply` 実行内の標準承認で続行するか判断します。先に実行した `mise run terra-plan` の結果を、apply が実行する plan と同一とはみなしません。

## import blocks

`terraform/github/imports.tf` は、既に存在する外部リソースを Terraform state に取り込むときの import block を管理します。既存リソースの adopt が必要な場合にだけ変更し、`locals.tf` の変更に連動して更新しません。
