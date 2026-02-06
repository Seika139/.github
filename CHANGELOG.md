# CHANGELOG

すべての注目すべき変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## Tagged Releases

## [Unreleased]

### Added

- **Overview**
  - 外部リポジトリからワークフローを呼び出す方法に関するリポジトリを作成した
    - [.github/workflows/](.github/workflows/): 実際に外部から呼び出されるワークフローを配置
    - [sample-reusable-workflows/](sample-reusable-workflows/): 外部リポジトリでの利用例を配置
- **terraform**
  - GitHub Actions の Secrets とブランチ保護ルールを管理するための Terraform 設定を追加
    - [terraform/github/main.tf](terraform/github/main.tf)
- **dotenvx**
  - `dotenvx` で環境変数を暗号化してGitHubに保存可能にした
  - terraform でも `dotenvx` を使用して Secrets を管理するようにした

### Changed

- リポジトリ初期状態からの特徴的な変更点
  - [lint-markdown.yml](.github/workflows/lint-markdown.yml): 呼び出し元のリポジトリにある `markdownlint-cli2.jsonc` を優先して使用するように変更
  - [uv-qualify](.github/workflows/uv-qualify.yml) ワークフロー: `mypy` チェックを並列化し効率を向上
