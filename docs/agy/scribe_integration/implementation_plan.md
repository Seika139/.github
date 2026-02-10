# scribe リポジトリの Terraform 管理統合

`Seika139/scribe` リポジトリを既存の GitHub 管理用 Terraform 構成に追加します。これには、ブランチ保護ルール、リポジトリの基本設定、および GitHub Actions/Dependabot 用のシークレットの管理が含まれます。

## 変更内容

### GitHub リポジトリ構成

#### [MODIFY] [locals.tf](../../../terraform/github/locals.tf)

`repositories` マップに `scribe` を追加します。

- **リポジトリ名**: `scribe`
- **説明**: "DeepgramとGeminiを活用した高精度な音声書き起こし・要約ツール"
- **デフォルトブランチ**: `main`
- **ルールセット**:
  - `main-protection`: `.github` リポジトリと同様の設定（削除禁止、非ファストフォワード禁止、ステータスチェック必須など）
  - **Status Checks**:
    - `call-common-markdownlint / markdownlint`
    - `call-common-uv-qualify (3.11) / lint-and-test`
    - `call-common-uv-qualify (3.12) / lint-and-test`
    - `call-common-uv-qualify (3.13) / lint-and-test`
    - `call-common-uv-qualify (3.14) / lint-and-test`
    - `call-common-uv-qualify (3.11) / mypy`
    - `call-common-uv-qualify (3.12) / mypy`
    - `call-common-uv-qualify (3.13) / mypy`
    - `call-common-uv-qualify (3.14) / mypy`
    - `call-common-uv-qualify (3.11) / setup`
    - `call-common-uv-qualify (3.12) / setup`
    - `call-common-uv-qualify (3.13) / setup`
    - `call-common-uv-qualify (3.14) / setup`
- **シークレット**:
  - `actions_secrets`: `PUSH_AND_RUN_WORKFLOW_TOKEN`, `DOTENV_PRIVATE_KEY`
  - `dependabot_secrets`: `PUSH_AND_RUN_WORKFLOW_TOKEN`, `DOTENV_PRIVATE_KEY`

### シークレット保護およびビルド成果物保護の追加 (Secret and Build Artifact Protection)

> [!CAUTION]
> **GitHub API の制限事項**
> 調査の結果、GitHub の「プッシュ時ルールセット (target = "push")」および「ファイルパス制限 (file_path_restriction)」は、**パブリックリポジトリかつ組織 (Organization) 所有ではないリポジトリ**では使用できないことが判明しました。
> 現在管理しているリポジトリ（.github, fried-shrimp, scribe）はすべて個人所有のパブリックリポジトリであるため、これらのルールを Terraform で設定しようとすると `422 Validation Failed` が発生します。

このため、以下の変更については取り消し（または設定の削除）を行います。

#### [REVERT] [repository module](../../../terraform/modules/repository/main.tf)

- 追加した `file_path_restriction` 関連の定義を削除またはコメントアウトします。

#### [REVERT] [locals.tf](../../../terraform/github/locals.tf)

- 追加した `do-not-push-secrets` および `no-build-artifacts` ルールセットを削除します。

今回の `scribe` リポジトリの統合（ブランチ保護、シークレット管理）自体は正常に完了しており、影響ありません。

## 検証計画

### 自動テスト

1. `terraform plan` を実行し、`scribe` リポジトリ、ルールセット、およびシークレットが正しく作成される（または既存のものが管理下に入る）ことを確認する。
    - 注意: すでにリポジトリが存在するため、`terraform import` が必要な場合があります。

### 手動確認

1. `terraform apply` 実行後、GitHub 上で `scribe` リポジトリの設定（Branch Rulesets）が反映されていることを確認する。
2. シークレットが正しく設定されていることを `gh secret list -R Seika139/scribe` で確認する。
