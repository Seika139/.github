# 実装計画: 自動修正コミットでの CI トリガー有効化

## 目的
`lint-markdown.yml` ワークフローが自動修正を行った際、`GITHUB_TOKEN` でプッシュしているため、後続の CI ワークフローがトリガーされず、マージに必要なステータスチェックが完了しない問題を解決します。
`PUSH_AND_RUN_WORKFLOW_TOKEN` (PAT) が利用可能な場合はそれを使用し、CI をトリガーするように変更します。

## ユーザーレビューが必要な事項
- `PUSH_AND_RUN_WORKFLOW_TOKEN` シークレットがリポジトリに設定されている必要があります。設定されていない場合は従来の `GITHUB_TOKEN` が使用され、挙動は変わりません。

## 変更内容

### .github
#### [MODIFY] [.github/workflows/lint-markdown.yml](file:///Users/suzukikenichi/programs/.github/.github/workflows/lint-markdown.yml)
- `ad-m/github-push-action` の `github_token` 入力を修正し、`PUSH_AND_RUN_WORKFLOW_TOKEN` を優先的に使用するように変更します。

## 検証計画
### 手動検証
- 修正後のコードを確認し、意図通り `secrets.PUSH_AND_RUN_WORKFLOW_TOKEN || secrets.GITHUB_TOKEN` になっているか確認します。
- 実際の動作確認は、この変更を含む PR がマージされた後の動作で確認します。
