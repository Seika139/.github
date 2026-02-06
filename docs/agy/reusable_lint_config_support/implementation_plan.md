# 実装計画 - 再利用可能ワークフローでのローカル設定適用のサポート

再利用可能な GitHub Actions ワークフローにおいて、呼び出し元のリポジトリが独自の設定ファイル
（`.markdownlint-cli2.jsonc` など）を持っている場合に、それを優先的に使用するように修正します。

## Proposed Changes

### GitHub Workflows

#### [MODIFY] [lint-markdown.yml](../../../.github/workflows/lint-markdown.yml)

- `Run markdownlint with auto-fix` ステップおよび `Run markdownlint (check only)` ステップのロジックを修正します。
- ローカルリポジトリのルートに以下のいずれかのファイルが存在するか確認します：
  - `.markdownlint-cli2.jsonc`
  - `.markdownlint-cli2.yaml`
  - `.markdownlint-cli2.json`
  - `.markdownlint-cli2.cjs`
  - `.markdownlint-cli2.mjs`
  - `.markdownlint.json`
  - `.markdownlint.yaml`
  - `.markdownlint.yml`
- 存在する場合は `--config` オプションを指定せずに `markdownlint-cli2` を実行します
  （`markdownlint-cli2` はデフォルトでカレントディレクトリの設定ファイルを自動探索します）。
- 存在しない場合は、従来通り共有リポジトリから取得した `$MARKDOWNLINT_CONFIG` を使用します。

## `markdown_glob` の扱いについて

既存の `markdown_glob` 入力は、廃止せず**共存させる**方針とします。理由は以下の通りです：

1. **役割の分離**:
   - `markdown_glob`: 「どのファイルを対象にするか」（Actions の変更検知や実行対象のフィルタリング）
   - 設定ファイル: 「どのようにチェックするか」（ルール、除外設定、プラグイン等）
2. **後方互換性**: 既存の呼び出し元（共有設定のみを利用しているリポジトリ）に影響を与えません。
3. **効率性**: `tj-actions/changed-files` 等での変更検知に使用されるため、
   リポジトリ全体ではなく変更されたファイルに関連する範囲のみを効率的にチェックできます。

> [!NOTE]
> `markdownlint-cli2` は引数で渡されたファイル/globを優先します。
> 呼び出し側がローカル設定の `globs` プロパティを完全に優先させたい場合は、
> `markdown_glob` に空文字や広いパターンを指定する運用になりますが、
> 基本的にはワークフロー側で制御する現在の方式が GitHub Actions の文脈では自然です。

## Verification Plan

### Manual Verification

- 修正後のシェルスクリプトのロジックをローカル端末でシミュレーションし、ファイルの存在有無によって実行コマンドが正しく切り替わることを確認します。
- 実際にワークフローをプルリクエストで実行し（可能であれば）、意図した設定が読み込まれているかログを確認します。
- `markdownlint-cli2` を使用して、修正した `task.md` や `implementation_plan.md` をフォーマットし、ドキュメント保存ルールに準拠させます。
