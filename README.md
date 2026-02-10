# .github

本リポジトリは、組織全体の GitHub 運用を効率化・標準化するための「ハブ」となるリポジトリです。
主に以下の2つの役割を担っています。

1. **GitHub Actions の共通化**: 複数のリポジトリで再利用可能なワークフロー（Reusable Workflows）の提供。
2. **Terraform によるリポジトリ管理**: リポジトリの設定（ブランチ保護ルール、Secrets、一般設定など）を IaC で一元管理。

<div align="center">
  <a href="https://github.com/Seika139/.github/actions/workflows/lint-yaml.yml">
    <img alt="Lint YAML" src="https://github.com/Seika139/.github/actions/workflows/lint-yaml.yml/badge.svg">
  </a>
  <a href="https://github.com/Seika139/.github/actions/workflows/lint-markdown.yml">
    <img alt="Lint Markdown" src="https://github.com/Seika139/.github/actions/workflows/lint-markdown.yml/badge.svg">
  </a>
  <a href="https://github.com/Seika139/.github/actions/workflows/shellcheck.yml">
    <img alt="ShellCheck" src="https://github.com/Seika139/.github/actions/workflows/shellcheck.yml/badge.svg">
  </a>
  <a href="https://github.com/Seika139/.github/releases/tag/v1.0.0">
    <img alt="version" src="https://img.shields.io/badge/version-v1.0.0-white.svg">
  </a>
</div>

## 関連ドキュメント

- [GitHub 公式: デフォルトのコミュニティ正常性ファイルの作成](https://docs.github.com/ja/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [GitHub 公式: ワークフロー、シークレット、およびランナーの共有](https://docs.github.com/ja/actions/administering-github-actions/sharing-workflows-secrets-and-runners-with-your-organization)

## リポジトリ構成

- **[.github/workflows/](.github/workflows/)**: 他のリポジトリから呼び出し可能な Reusable Workflows を配置。
- **[sample-reusable-workflows/](sample-reusable-workflows/)**: 外部リポジトリで利用する際のサンプル。
- **[terraform/](terraform/)**: Seika139 の GitHub リポジトリ設定（Rulesets, Secrets 等）をまとめて管理する Terraform コード。
- **[mise.toml](mise.toml)**: タスクランナー
- **[mise/](mise/)**: mise.toml では長くなるようなタスクを shell script として定義。

## セットアップ

### 共通ワークフローの利用

他のリポジトリで当リポジトリのワークフローを利用するための設定です。

#### 1. Workflow permissions の設定

- 本リポジトリ (`.github`) の `Settings` > `Actions` > `General` を開く
  - `Actions permissions`: `Allow all actions and reusable workflows` に設定
  - `Workflow permissions` > `Access`: `Accessible from repositories in <your-org>` に設定

#### 2. Secrets の登録

- ユーザーの `Settings` > `Developer Settings` で `Personal Access Token (classic)` を作成
  - 権限: `repo`, `workflow`, `write:packages`
- 呼び出し側のリポジトリの `Settings` > `Secrets and variables` > `Actions` に以下を登録
  - Name: `PUSH_AND_RUN_WORKFLOW_TOKEN`
  - Value: 作成したトークン

## 関連ドキュメント

- [CHANGELOG.md](CHANGELOG.md)
- [GitHub 公式: デフォルトのコミュニティ正常性ファイルの作成](https://docs.github.com/ja/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [GitHub 公式: ワークフロー、シークレット、およびランナーの共有](https://docs.github.com/ja/actions/administering-github-actions/sharing-workflows-secrets-and-runners-with-your-organization)
