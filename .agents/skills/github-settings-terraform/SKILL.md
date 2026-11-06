---
name: github-settings-terraform
description: GitHub repository や organization 自体の設定を変更するときに使います。設定の正本は `$HOME/programs/.github` の Terraform です。workflow などリポジトリ内ファイルだけの変更には、Terraform 設定も必要な場合を除いて使いません。
---

# GitHub 設定の Terraform 管理

Seika139 のアカウントに紐づく GitHub repository / organization settings の変更は `$HOME/programs/.github` の Terraform を通して行います。`gh api`、GitHub UI、MCP などで設定を直接変更してはいけません。これらは Terraform が管理する設定の source of truth ではありません。

Terraform の設定、state、または実行タスクを調査・変更・実行する前に `$HOME/programs/.github/AGENTS.md` と `$HOME/programs/.github/.agents/skills/terraform-operations/SKILL.md` を読み、その手順と制約に従います。HCP workspace の設定、state 移行、実行環境の接続に関わる場合は `$HOME/programs/.github/README.md` の HCP Terraform 手順も読みます。

要求された設定が Terraform でどう管理されているか確認し、既存の precondition と plan 上の visibility / repository eligibility 制約を保ちます。plan で目的の機能が利用できないと分かった場合は Terraform の guard を回避・弱体化せず、plan の根拠と必要条件を説明して停止します。

Terraform の apply は、ユーザーが GitHub 設定の変更を明示的に依頼または許可した場合に限ります。apply 前に plan を確認し、運用 skill の承認手順に従います。
