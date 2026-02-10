# GitHubリポジトリ管理移行タスク

- [x] Terraform構成の設計とディレクトリ構造の決定
- [x] モジュール化の実装
  - [x] `terraform/github/modules/repository/` の作成
  - [x] リポジトリ・ルールセット・シークレット設定の共通化
- [x] メイン構成のリファクタリング
  - [x] `terraform/github/locals.tf` の作成（`.repositories`を参考に）
  - [x] `terraform/github/main.tf` の更新（`for_each`によるモジュール呼び出し）
- [x] 動作確認
  - [x] `terraform validate`
  - [x] `terraform plan`（既存設定への影響確認）
- [x] `fried-shrimp` リポジトリのインポートと適用
  - [x] `import` ブロックによる既存リソースの取り込み
  - [x] `terraform apply` の実行
- [x] ドキュメント作成
  - [x] `walkthrough.md` の作成
