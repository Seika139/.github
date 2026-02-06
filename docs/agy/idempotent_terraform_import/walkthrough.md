# Walkthrough - Idempotent Terraform Import

Terraform のリソースインポート処理を、従来の命令的なコマンド実行 (`terraform import`) から、宣言的な `import` ブロックを使用する方法に変更しました。これにより、スクリプトの冪等性が確保され、GitHub Actions や他の CI/CD パイプラインでの実行が安全になりました。

## Changes

### Terraform Configuration

#### [terraform/github/main.tf](terraform/github/main.tf)

`github_repository.repo` リソースに対する `import` ブロックを追加しました。これにより、`var.github_repository_full_name` で指定されたリポジトリが自動的にインポート対象として管理されます。

```hcl
import {
  to = github_repository.repo
  id = var.github_repository_full_name
}
```

### Script Cleanup

#### [mise/tasks/terra-github.sh](mise/tasks/terra-github.sh)

`terraform import` を実行する条件分岐ブロックを削除しました。今後は `terraform plan` および `apply` の実行時に、Terraform が自動的にインポートの必要性を判断します。

## Verification Results

### Automated Tests

- `terraform validate` を実行し、設定ファイルの構文が正しいことを確認しました。
- `bash -n` を実行し、シェルスクリプトに構文エラーがないことを確認しました。

### Manual Verification

この変更により、初回実行時も2回目以降の実行時も、同じ `terraform plan / apply` フローで処理されるようになります。インポート済みであれば何も変更されず（No changes）、未インポートであればインポートが計画されます。
