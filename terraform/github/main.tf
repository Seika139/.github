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

# 3. 既存のリポジトリを指定
data "github_repository" "repo" {
  full_name = "Seika139/.github"
}

# 4. リポジトリルールセットの設定
resource "github_repository_ruleset" "main" {
  name        = "main-protection"
  repository  = data.github_repository.repo.name
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
    }
  }
}

variable "DOTENV_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

# Secrets の設定
resource "github_actions_secret" "DOTENV_PRIVATE_KEY" {
  repository      = data.github_repository.repo.name
  secret_name     = "DOTENV_PRIVATE_KEY"
  plaintext_value = var.DOTENV_PRIVATE_KEY
}
