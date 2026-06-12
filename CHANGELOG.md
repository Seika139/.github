# CHANGELOG

すべての注目すべき変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## Tagged Releases

- [unreleased](https://github.com/Seika139/.github/compare/v1.2.0...HEAD)
- [1.2.0](https://github.com/Seika139/.github/compare/v1.1.1...v1.2.0)
- [1.1.1](https://github.com/Seika139/.github/compare/v1.1.0...v1.1.1)
- [1.1.0](https://github.com/Seika139/.github/compare/v1.0.0...v1.1.0)
- [1.0.0](https://github.com/Seika139/.github/releases/tag/v1.0.0)

## [Unreleased]

### Added

- Terraform の GitHub 管理対象に `airline-sale-monitor` を private リポジトリとして追加
- `mise.toml` に `[tools]` セクションを追加し、`dotenvx` と `terraform` を mise 管理に変更

## [1.2.0] - 2026-04-24

### Added

- Terraform リポジトリモジュールで `visibility`（`public`/`private`）と `has_wiki` を指定可能に変更し、private リポジトリを管理対象に追加
- Terraform の GitHub 管理対象に `dotfiles` / `aws-cost-dashboard` / `claw-knowledge` / `second-brain` / `discord-notify` / `repo-sync` / `zipper` を追加
- `discord-notify` / `repo-sync` / `zipper` の `main` ブランチに保護ルール（強制プッシュ禁止・削除禁止・必須ステータスチェック）を設定
- [lint-markdown.yml](.github/workflows/lint-markdown.yml) に `rumdl` 対応を追加し、呼び出し元の設定有無に応じて rumdl / markdownlint-cli2 / 共有 rumdl 設定を自動選択 ([#27](https://github.com/Seika139/.github/pull/27))
- 共有 rumdl 設定 [.github/config/.rumdl.toml](.github/config/.rumdl.toml) を追加
- `mise/tasks` の `check` / `format` に rumdl 経由の Markdown lint を追加（`markdownlint-cli2` は fallback として維持）
- [dependabot.yml](.github/dependabot.yml) に `github-actions` エコシステムの weekly 更新設定を追加

### Changed

- [lint-markdown.yml](.github/workflows/lint-markdown.yml) のデフォルト Linter を `markdownlint-cli2` から `rumdl`（公式 Action `rvben/rumdl@v0`）に切り替え ([#28](https://github.com/Seika139/.github/pull/28), [#31](https://github.com/Seika139/.github/pull/31))
- Terraform リポジトリモジュールのルールセットで `strict_required_status_checks_policy` を無効化し、base ブランチ追従を必須としない運用に変更
- GitHub Actions 依存関係を更新: `actions/upload-artifact@v7`, `actions/upload-pages-artifact@v5`, `actions/deploy-pages@v5`
- uv 依存関係を更新: `ruff`, `mypy`, `pytest`, `ty`, `pygments` など

### Fixed

- [shellcheck.yml](.github/workflows/shellcheck.yml) から存在しない `--rcfile` オプションを削除し、`.shellcheckrc` のルート自動検出に統一 ([#38](https://github.com/Seika139/.github/pull/38))
- Terraform リポジトリモジュールで個人アカウントの `allow_forking` 変更が API エラーになる問題を `lifecycle.ignore_changes` で回避
- `rumdl` 実行時の fix/stage 不整合およびネスト設定検出の不具合を修正

### Removed

- 共有設定 `.github/config/.markdownlint-cli2.jsonc` を削除し、rumdl の共有設定に集約

## [1.1.1] - 2026-02-17

### Added

- Terraform の GitHub 管理に dotfiles リポジトリを追加
- Terraform のルールセットに bypass ルールを追加
- [dependabot.yml](.github/dependabot.yml) に github-actions のアップデートを許可する設定を追加
- Terraform の GitHub 管理において [imports.tf](terraform/github/imports.tf) を作成し、既存の GitHub リポジトリをインポートする機能を追加

### Fixed

- Terraform の実行ジョブを plan と apply に分割

## [1.1.0] - 2026-02-11

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
