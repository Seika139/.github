# Implementation Plan - Use Declarative Import for Idempotency

スクリプト `mise/tasks/terra-github.sh` 内の `terraform import` コマンドが再実行時に失敗する問題を解決するため、Terraform の宣言的な `import` ブロックを使用するように変更します。これにより、GitHub上での管理が容易になり、スクリプトが普遍的（冪等）に動作するようになります。

## User Review Required

> [!NOTE]
> Terraform v1.5 以上が必要です。現在の環境は v1.14.4 なので問題ありません。

## Proposed Changes

### terraform/github

#### [MODIFY] [main.tf](terraform/github/main.tf)

- `import` ブロックを追加し、`github_repository.repo` リソースを宣言的にインポートするように設定します。
- IDには変数 `var.github_repository_full_name` を使用します。

### mise/tasks

#### [MODIFY] [terra-github.sh](mise/tasks/terra-github.sh)

- 明示的な `terraform import` コマンドの実行ブロックを削除します。
- `terraform plan` および `apply` のみが実行されるようにします。

## Verification Plan

### Automated Tests

- `terraform validate` を実行し、構文が正しいことを確認します。
- `terraform plan` を実行し、既存のリソースに対してインポートまたは変更なし（No changes）となることを確認します。
