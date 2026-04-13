locals {
  # GitHub Actions integration ID
  github_actions_integration_id = var.github_actions_integration_id

  # Secret 値のマッピング（変数名 → 値）
  secret_values = {
    PUSH_AND_RUN_WORKFLOW_TOKEN = var.PUSH_AND_RUN_WORKFLOW_TOKEN
    DOTENV_PRIVATE_KEY          = var.DOTENV_PRIVATE_KEY
  }

  repositories = {
    ".github" = {
      description    = "GitHub上での共通設定を管理するためのリポジトリ"
      default_branch = "main"
      rulesets = {
        "main-protection" = {
          target           = "branch"
          enforcement      = "active"
          include_refs     = ["~DEFAULT_BRANCH"]
          exclude_refs     = []
          deletion         = true
          non_fast_forward = true
          pull_request = {
            required_approving_review_count   = 0
            dismiss_stale_reviews_on_push     = true
            required_review_thread_resolution = true
          }
          required_status_checks = ["markdownlint", "shellcheck", "yamllint", "mypy", "lint-and-test", "setup"]
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
    }

    "dotfiles" = {
      description        = "dotfiles"
      default_branch     = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "fried-shrimp" = {
      description    = "Your own personal AI assistant. Any OS. Any Platform. The lobster way. 🦞"
      homepage_url   = "https://openclaw.ai"
      default_branch = "develop"
      rulesets = {
        "develop-protection" = {
          target           = "branch"
          enforcement      = "active"
          include_refs     = ["refs/heads/develop"]
          exclude_refs     = []
          deletion         = true
          non_fast_forward = true
          pull_request = {
            required_approving_review_count   = 0
            dismiss_stale_reviews_on_push     = true
            required_review_thread_resolution = true
          }
          required_status_checks = ["call-common-markdownlint / markdownlint"]
          bypass_actors = [
            {
              actor_id    = 5
              actor_type  = "RepositoryRole"
              bypass_mode = "always"
            }
          ]
        }
        "main-protection" = {
          target                 = "branch"
          enforcement            = "active"
          include_refs           = ["refs/heads/main"]
          exclude_refs           = []
          deletion               = true
          non_fast_forward       = false # upstream 同期を許可
          pull_request           = null
          required_status_checks = []
        }
      }
      actions_secrets    = []
      dependabot_secrets = []
    }
    "claw-knowledge" = {
      description    = "LLMを利用した開発で得た知見をまとめる"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "second-brain" = {
      description        = "個人用ナレッジリポジトリ（Markdown + AI検索）"
      visibility         = "private"
      has_wiki           = false
      default_branch     = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "scribe" = {
      description    = "DeepgramとGeminiを活用した高精度な音声書き起こし・要約ツール"
      default_branch = "main"
      rulesets = {
        "main-protection" = {
          target           = "branch"
          enforcement      = "active"
          include_refs     = ["~DEFAULT_BRANCH"]
          exclude_refs     = []
          deletion         = true
          non_fast_forward = true
          pull_request = {
            required_approving_review_count   = 0
            dismiss_stale_reviews_on_push     = true
            required_review_thread_resolution = true
          }
          required_status_checks = flatten([
            "call-common-markdownlint / markdownlint",
            [
              for version in ["3.11", "3.12", "3.13", "3.14"] : [
                for check in ["lint-and-test", "mypy", "setup"] :
                "call-common-uv-qualify (${version}) / ${check}"
              ]
            ]
          ])
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
    }

    "discord-notify" = {
      description        = "外部依存ゼロの Discord Webhook クライアント（Python 標準ライブラリのみ）"
      default_branch     = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "repo-sync" = {
      description        = "ローカル git リポジトリを GitHub と自動同期する CLI（discord-notify 連携）"
      default_branch     = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }
  }
}
