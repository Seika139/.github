# 機密情報の保護と for_each エラーの解決

`actions_secrets` などのマップに機密情報が含まれている場合、Terraform はそのマップを `for_each` に直接使うことを制限します。これは、リソースのキー（名前）に機密情報が混入するのを防ぐための安全策です。

## 解決策の概要

シークレットの「名前（キー）」は機密ではありませんが、「値」は機密です。Terraform において、マップのキーだけを `nonsensitive()` 関数で明示的に非機密として扱うことで、`for_each` で安全に使用しつつ、値の機密性を維持できます。

## 提案される変更

### [Component Name] Terraform Module (repository)

#### [MODIFY] [main.tf](../../../terraform/modules/repository/main.tf)

1. 変数の `sensitive = true` 指定を復活させます。
2. `for_each` で `nonsensitive(toset(keys(...)))` を使用するように変更します。

```hcl
resource "github_actions_secret" "this" {
  for_each        = nonsensitive(toset(keys(var.actions_secrets)))
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = var.actions_secrets[each.key]
}
```

## 検証プラン

### 自動テスト

- `terraform -chdir=terraform/github validate`
- `terraform -chdir=terraform/github plan`
- 出力結果に実際のシークレットの値が表示されていない（`(sensitive value)` と表示されている）ことを確認します。
