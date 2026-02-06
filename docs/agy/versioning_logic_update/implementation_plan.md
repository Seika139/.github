# 実装計画: バージョン管理ロジックの汎用化

`pyproject.toml` に依存せず、Git タグを利用して次バージョンを決定できるようにします。また、Python/uv を使用していないプロジェクトでもワークフローが正常に動作するように改善します。

## Proposed Changes

### [Component Name] Shared Scripts

#### [MODIFY] [determine_next_version.py](../../../.github/scripts/determine_next_version.py)

- `read_current_version` 関数を以下の優先順位でバージョンを取得するように変更します：
  1. 指定された `pyproject.toml` (または代替ファイル) 内の `version = "..."`
  2. Git タグの最新版 (`git tag --sort=-v:refname`)
  3. いずれも見つからない場合は `0.0.0`
- Git コマンド実行のために `subprocess` モジュールを使用します。

---

### [Component Name] GitHub Actions Workflows

#### [MODIFY] [update-version.yml](../../../.github/workflows/update-version.yml)

- `pyproject.toml` の有無をチェックするステップを追加します。
- 以下のステップを `pyproject.toml` が存在する場合のみ実行するように変更します：
  - `Update pyproject version`
  - `Update lockfile` (`uv lock`)
- `Commit changes` ステップでの `git add` 対象を、存在するファイルのみに制限します。

## Verification Plan

### Automated Tests

- 本プロジェクト（`pyproject.toml` あり）でワークフローが正常に動作し、バージョンが更新されることを確認します。
- ダミーのディレクトリで `pyproject.toml` を除いた状態でスクリプトを実行し、Git タグから正しくバージョンが取得できるかテストします。

### Manual Verification

- リポジトリに `v0.1.0` などのタグを手動で打ち、スクリプトがそれを認識するか確認する。
- `pyproject.toml` を一時的にリネームして、ワークフローがスキップされるべきステップを正しくスキップするか確認する。
