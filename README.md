# .github

This directory contains GitHub-specific files, such as issue and pull request templates, and GitHub Actions workflows for automating tasks related to the repository.

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

## See Also

- <https://docs.github.com/ja/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file>
- <https://docs.github.com/ja/actions/administering-github-actions/sharing-workflows-secrets-and-runners-with-your-organization>

## Setup

他のリポジトリで当リポジトリのワークフローを利用するための設定

### Workflow permissions

- .github リポジトリの settings > Actions > General を開く
  - `Actions permissions` が `Allow all actions and reusable workflows` になっていることを確認する
  - `Workflow permissions` > `Access` が `Accessible from repositories in <your-org>` になっていることを確認する

### Secrets

- ユーザーの Settings > Developer Settings で Personal Access Token (classic) を作成する
  - 権限は repo, workflow, write:packages
- 作成したトークンを控えておく
- 呼び出す側のリポジトリの Settings > Secrets and variables > Actions を開いて Repository Secrets を追加する
  - Name に `PUSH_AND_RUN_WORKFLOW_TOKEN` を、Value に先程控えたトークンを張り付けて登録する
