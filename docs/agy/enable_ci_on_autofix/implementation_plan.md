# 実装計画: 自動修正コミットでの CI トリガー有効化 (修正版)

## 目的
`lint-markdown.yml` ワークフローからの自動修正コミットが CI をトリガーしない問題を、より確実な方法で解決します。
`ad-m/github-push-action` の使用をやめ、`actions/checkout` で PAT (Personal Access Token) を認証に使用し、標準的な `git push` コマンドを使用する方法に変更します。

## ユーザーレビューが必要な事項
- `PUSH_AND_RUN_WORKFLOW_TOKEN` がリポジトリのシークレットに設定されていること（前提条件）。

## 変更内容

### .github
#### [MODIFY] [.github/workflows/lint-markdown.yml](file:///Users/suzukikenichi/programs/.github/.github/workflows/lint-markdown.yml)
- `Checkout` ステップ: `token` 入力を追加し、`secrets.PUSH_AND_RUN_WORKFLOW_TOKEN || secrets.GITHUB_TOKEN` を使用するように変更します。
- `Push changes` ステップ:
  - `ad-m/github-push-action` を削除します。
  - `git push origin HEAD:${{ github.head_ref }}` を直接実行します。

## 検証計画
### 手動検証
- 修正後のワークフローが `.git/config` を正しく設定し、プッシュが成功することを確認します（実際の PR 上での動作）。
- プッシュされたコミットに対して、他の CI ワークフロー（yamllint, shellcheck 等）が開始されることを確認します。
