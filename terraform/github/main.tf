# 1. 使用するプロバイダ（GitHub）の定義
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# 2. GitHubへの接続設定
# token と owner は環境変数 GITHUB_TOKEN, GITHUB_OWNER から自動的に読み込まれます
provider "github" {}

variable "github_repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository (e.g., 'owner/repo')."
}

# 3. 既存のリポジトリを指定
import {
  to = github_repository.repo
  id = split("/", var.github_repository_full_name)[1]
}

resource "github_repository" "repo" {
  name                   = split("/", var.github_repository_full_name)[1]
  delete_branch_on_merge = true
  allow_update_branch    = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  vulnerability_alerts   = true
}

# 4. リポジトリルールセットの設定
resource "github_repository_ruleset" "main" {
  name        = "main-protection"
  repository  = github_repository.repo.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    # ブランチの削除を禁止
    deletion = true

    # 強制プッシュを禁止（Non-fast-forward pushの禁止）
    non_fast_forward = true

    # マージにはプルリクエストを必須にする
    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = true
      require_code_owner_review         = false
      require_last_push_approval        = false
    }

    # ステータスチェック（ lint など）を必須にする
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context        = "markdownlint"
        integration_id = 15368 # GitHub Apps の固定App ID
      }
      required_check {
        context        = "yamllint"
        integration_id = 15368 # GitHub Apps の固定App ID
      }
      required_check {
        context        = "shellcheck"
        integration_id = 15368 # GitHub Apps の固定App ID
      }
      required_check {
        context        = "lint-and-test"
        integration_id = 15368
      }
      required_check {
        context        = "mypy"
        integration_id = 15368
      }
      required_check {
        context        = "setup"
        integration_id = 15368
      }
    }
  }
}

# Secrets の設定
variable "DOTENV_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

variable "PUSH_AND_RUN_WORKFLOW_TOKEN" {
  type      = string
  sensitive = true
}

locals {
  # まとめて管理したいシークレットを map で定義
  repo_secrets = {
    "DOTENV_PRIVATE_KEY"          = var.DOTENV_PRIVATE_KEY
    "PUSH_AND_RUN_WORKFLOW_TOKEN" = var.PUSH_AND_RUN_WORKFLOW_TOKEN
  }
}

# Actions用シークレット（一括生成）
resource "github_actions_secret" "this" {
  for_each        = local.repo_secrets
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}

# Dependabot用シークレット（一括生成）
resource "github_dependabot_secret" "dependabot" {
  for_each        = local.repo_secrets
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}
