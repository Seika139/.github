# CHANGELOG

すべての注目すべき変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## Tagged Releases

- [unreleased](https://github.com/Seika139/.github/compare/v1.0.0...HEAD)
- [1.0.0](https://github.com/Seika139/.github/releases/tag/v1.0.0)

## [Unreleased]

### Added

- Terraform による GitHub リポジトリ管理をモジュール化 ([terraform/modules/repository/](terraform/modules/repository/))
- リポジトリの General Settings (`delete_branch_on_merge`, `allow_update_branch` 等) を Terraform 管理下に追加
- `mise` タスクの追加と整理 (lint, format, venv 管理等) および共通処理の抽出 ([mise/common.sh](mise/common.sh))
- `PUSH_AND_RUN_WORKFLOW_TOKEN` を GitHub Secrets に追加

### Fixed

- `github-actions[bot]` によるファイル修正時に CI が実行されない問題を修正

## [1.0.0] - 2026-02-07

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
