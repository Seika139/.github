# fried-shrimp リポジトリの統合計画

`fried-shrimp` リポジトリの特殊な設定（デフォルトブランチが `develop`、upstream 同期用のルールセットなど）を取り込むため、`repository` モジュールを拡張し、`locals.tf` に定義を追加します。

## 変更内容

### 1. `repository` モジュールの拡張

- `default_branch`: デフォルトブランチ（`develop` 等）を指定可能にする。
- `homepage_url`: リポジトリの Web サイト URL を指定可能にする。
- **ルールセットの動的定義**: 現在はメインブランチ固定ですが、対象ブランチや `non_fast_forward` 許可設定を指定可能にします。

### 2. `locals.tf` への `fried-shrimp` の追加

- `fried-shrimp` の設定（説明、URL、デフォルトブランチ、ルールセット）を定義します。

## Proposed Changes

### [Terraform]

#### [MODIFY] [modules/repository/main.tf](../../terraform/modules/repository/main.tf)

- `default_branch`, `homepage_url` 変数の追加。
- `github_branch_default` リソースの追加。
- `github_repository_ruleset` を `dynamic` またはマップによる `for_each` で定義できるように修正。

#### [MODIFY] [terraform/github/locals.tf](../../terraform/github/locals.tf)

- `fried-shrimp` の設定データを追加。

## Verification Plan

### Automated Tests

- `terraform validate`: 構文チェック。
- `terraform plan`: `fried-shrimp` が新規管理対象として認識され、意図した通りの設定（develop保護、mainの非FFプッシュ許可など）が適用されることを確認。

### Manual Verification

- `mise run terra-github` を実行し、plan 結果をユーザーが確認。
- 実際に `terraform apply` を行い、GitHub 上のリソースが既存の状態を維持しつつ管理下に入ることを確認。
