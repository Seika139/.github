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
  <a href="https://github.com/Seika139/.github/releases/tag/v1.3.0">
    <img alt="version" src="https://img.shields.io/badge/version-v1.3.0-white.svg">
  </a>
</div>

## リポジトリ構成

- **[.github/workflows/](.github/workflows/)**: 他のリポジトリから呼び出し可能な Reusable Workflows を配置。
- **[sample-reusable-workflows/](sample-reusable-workflows/)**: 外部リポジトリで利用する際のサンプル。
- **[terraform/](terraform/)**: Seika139 の GitHub リポジトリ設定（Rulesets, Secrets 等）をまとめて管理する Terraform コード。
- **[mise.toml](mise.toml)**: タスクランナー
- **[mise/](mise/)**: mise.toml では長くなるようなタスクを shell script として定義。

## セットアップ

### Terraform state の共有（HCP Terraform）

Terraform の state は HCP Terraform に保存し、plan/apply は各 PC または VPS 上の Terraform CLI から実行します。HCP Terraform の `github-repositories` workspace で `Settings` > `General` > `Execution Mode` が `Local` になっていることを確認してください。このモードでは HCP Terraform は state を保管し、Terraform の実行は各端末上で行われます。

各実行環境で一度 `terraform login` を実行して HCP Terraform にログインしてください。認証は実行ユーザーの Terraform CLI credentials に保存されるため、PC と VPS のそれぞれで必要です。GitHub provider が使う認証情報や dotenvx の secrets は、これまでどおり各 PC/VPS 側で管理します。Local execution mode では HCP workspace variables は使われません。GitHub provider の認証情報を HCP workspace に登録しないでください。

### Token の Expiration

トークンの漏洩リスクを低減するためにはトークンの有効期間を短くすることが推奨されます。
`terraform login` でトークンがない場合、またはトークンの有効期限が切れている場合はトークンを再作成します。

#### 初回のみ: VPS の最新 state を HCP に移行する

初回移行の前に、VPS の Terraform 実行を止め、HCP の `seika139-github/github-repositories` workspace が空で、Execution Mode が `Local` であることを確認してください。VPS の `terraform/github/terraform.tfstate` をリポジトリ外の安全な場所にバックアップしてください。state には秘密情報が含まれる場合があるため、バックアップを Git に追加したり共有場所へ不用意に置いたりしないでください。

state 移行時は、VPS で state を操作していた Terraform CLI と同じバージョンを使ってください。VPS の `~/programs/.github` で `terraform version` を実行してバージョンを確認し、表示されたバージョンを `X.Y.Z` に指定して `mise use --pin --path mise.toml terraform@X.Y.Z` を実行します。`mise.toml` の Terraform バージョンがその値になったことを確認し、`mise install` と `terraform version` で実行バージョンが一致することを確認してください。これは共有設定の変更なので、PC 側でも同じ `mise.toml` と Terraform バージョンを使います。

VPS で state をバックアップします。`~/programs/.github` で次を実行してください。バックアップ先はリポジトリ外で、所有ユーザー以外が読めない権限になります。

```sh
set -e
umask 077
mkdir -p "$HOME/.local/state"
backup_dir="$HOME/.local/state/github-repositories-hcp-migration-$(date +%Y%m%d%H%M%S)-$$"
mkdir "$backup_dir"
test -f terraform/github/terraform.tfstate
for path in \
  terraform/github/terraform.tfstate \
  terraform/github/terraform.tfstate.backup \
  terraform/github/terraform.tfstate.d; do
  if [ -e "$path" ]; then
    cp -R -p "$path" "$backup_dir/"
  fi
done
if [ -e terraform/github/.terraform/terraform.tfstate ]; then
  mkdir -p "$backup_dir/.terraform"
  cp -p terraform/github/.terraform/terraform.tfstate "$backup_dir/.terraform/"
fi
chmod -R go-rwx "$backup_dir"
```

VPS 上で `terraform login` が済んでいることを確認し、`~/programs/.github` で次を実行します。通常の `init` は既存 local state を HCP workspace に移行するか対話で確認します。初回移行より前に `mise run init` を実行しないでください。

```sh
terraform -chdir=terraform/github init
```

Terraform がローカル state を HCP workspace にコピーするか尋ねたら、接続先 organization/workspace と移行元が VPS の最新 state であることを確認してから移行を承認してください。移行後は `terraform -chdir=terraform/github state list` のリソースアドレスが想定どおりか照合し、`mise run terra-plan` で plan を確認してください。このタスクは dotenvx を通じて GitHub provider 用のローカル secrets を渡します。大量の予期しない create/destroy など不審な差分があれば、apply せずに停止して state と workspace の接続先を調べてください。

#### 2台目以降の実行環境

HCP への初回 state 移行が完了したら、他の各 PC/VPS で `terraform login` を行い、古い local state と backend metadata をリポジトリ外の権限を限定した場所に退避してから `mise run init` を実行してください。各端末で `~/programs/.github` に移動し、以下を実行すると state ファイル、バックアップ、local workspace state、および `.terraform` の backend metadata を同じユーザーだけが読めるディレクトリーに移せます。

```sh
set -e
umask 077
mkdir -p "$HOME/.local/state"
backup_dir="$HOME/.local/state/github-repositories-before-hcp-$(date +%Y%m%d%H%M%S)-$$"
mkdir "$backup_dir"
for path in \
  terraform/github/terraform.tfstate \
  terraform/github/terraform.tfstate.backup \
  terraform/github/terraform.tfstate.d; do
  if [ -e "$path" ]; then
    mv "$path" "$backup_dir/"
  fi
done
if [ -e terraform/github/.terraform/terraform.tfstate ]; then
  mkdir -p "$backup_dir/.terraform"
  mv terraform/github/.terraform/terraform.tfstate "$backup_dir/.terraform/"
fi
chmod -R go-rwx "$backup_dir"
```

退避先を確認した後、各端末で `mise run init` を実行してください。この task は通常の `terraform init` を行うため、local state が残っていると移行確認が表示されることがあります。VPS の最新 state を移行済みの HCP workspace に接続する端末では、古い state を移行元として選ばないよう、必ず先に退避してください。Terraform の実行前に dotenvx/GitHub provider 用 secrets がその端末で利用できることも確認してください。

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

### Dependabot PR の自動マージ

Dependabot が作成した PR のうち CI が通ったものを自動マージする reusable workflow です。[sample-reusable-workflows/dependabot-auto-merge.yml](sample-reusable-workflows/dependabot-auto-merge.yml) を呼び出し側リポジトリの `.github/workflows/` にそのまま配置してください。reusable workflow は呼び出し元から渡されたトークン権限を降格することしかできず昇格できないため、caller 側のワークフローファイルに `permissions: contents: write` / `pull-requests: write` を必ず記述する必要があります。

前提条件:

- 呼び出し側リポジトリの `Settings` > `General` > `Pull Requests` で `Allow auto-merge`（Terraform では `allow_auto_merge`）が有効になっていること
- 呼び出し側リポジトリの既定ブランチを保護する active な branch ruleset に `required_status_checks` が 1 本以上設定されていること。required check が無いリポジトリで auto-merge を予約すると、待つ対象が存在しないため即時マージと同義になります

**警告: private リポジトリには設定しないでください。** GitHub Free では private リポジトリの `allow_auto_merge` は API がエラーを返さず値を黙って捨てるため、Terraform が refresh のたびに差分を検出し `terraform plan` が恒久的に収束しなくなります。適用対象は public リポジトリに限定してください。

上記 2 点の不変条件は `terraform/modules/repository/main.tf` の `github_repository.repo` に `precondition` として実装されており、`allow_auto_merge = true` を private リポジトリに設定した場合や、既定ブランチを保護する active な branch ruleset に `required_status_checks` を持つものが 1 つも無い場合は `terraform plan`/`apply` がエラーで停止します（`enforcement = "disabled"` の ruleset や、既定ブランチを対象にしない/除外する ruleset の check は数えません）。README の警告文はこの機械的なチェックを補足するものです。

## 関連ドキュメント

- [CHANGELOG.md](CHANGELOG.md)
- [GitHub 公式: デフォルトのコミュニティ正常性ファイルの作成](https://docs.github.com/ja/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [GitHub 公式: ワークフロー、シークレット、およびランナーの共有](https://docs.github.com/ja/actions/administering-github-actions/sharing-workflows-secrets-and-runners-with-your-organization)
