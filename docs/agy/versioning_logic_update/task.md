# タスク: バージョン管理ロジックの改善

`pyproject.toml` がないプロジェクトでも、Gitタグを使用してバージョン管理とリリースが行えるように改善します。

- [x] 調査と設計
- [x] `determine_next_version.py` の修正
  - [x] Gitタグから最新バージョンを取得するロジックの追加
  - [x] `pyproject.toml` がない、またはバージョンが記載されていない場合のフォールバック実装
- [x] `update-version.yml` の修正
  - [x] `pyproject.toml` の有無を確認するステップの追加
  - [x] Python/uv 依存のステップを条件付き（`pyproject.toml` がある場合のみ）にする
  - [x] `git add` 対象ファイルの存在確認
- [x] 動作確認
- [x] Lint エラーの修正 (`ruff`)
- [x] ドキュメントの保存 (`docs/agy/versioning_logic_update/`)
