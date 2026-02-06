# 修正内容の確認 - 再利用可能ワークフローでのローカル設定適用のサポート

再利用可能なワークフロー `.github/workflows/lint-markdown.yml` において、
呼び出し元のリポジトリに `markdownlint` の設定ファイルが存在する場合、それを優先して使用するように変更しました。

## 変更内容

### GitHub Workflows

#### [MODIFY] [lint-markdown.yml](../../../.github/workflows/lint-markdown.yml)

- `Run markdownlint with auto-fix` および `Run markdownlint (check only)` ステップを修正しました。
- 以下の順序で設定を優先します：
  1. ローカルリポジトリの設定ファイル（`.markdownlint-cli2.jsonc`, `.markdownlint.yaml` 等）
  2. 共有リポジトリの共用設定ファイル (`$MARKDOWNLINT_CONFIG`)
  3. 設定ファイルがない場合のデフォルトルール
- `markdown_glob` は引き続き実行対象の絞り込みに使用され、共存可能です。
- **YAML 内に優先順位に関する注意書きを追加しました**（`markdown_glob` 引数は設定ファイル内の `globs` プロパティより優先される旨）。

## 検証結果

### 自動テスト（シェルスクリプトによるロジック検証）

以下の 4 つのケースについて、期待通りの動作（実行コマンドの切り替え）をすることを確認しました。

| ケース | ローカル設定 | 共有設定 | 結果             | 実行コマンド                             |
| :----- | :----------- | :------- | :--------------- | :--------------------------------------- |
| 1      | あり         | あり     | **ローカル優先** | `markdownlint-cli2 --fix "**/*.md"`      |
| 2      | あり         | なし     | **ローカル使用** | `markdownlint-cli2 --fix "**/*.md"`      |
| 3      | なし         | あり     | **共有設定使用** | `markdownlint-cli2 --config "..." --fix` |
| 4      | なし         | なし     | デフォルト       | `markdownlint-cli2 --fix "**/*.md"`      |

### 実行ログ（イメージ）

ログに以下が表示されます：
`Local markdownlint configuration found. Using it.`
