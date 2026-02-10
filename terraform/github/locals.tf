locals {
  # GitHub Actions integration ID
  github_actions_integration_id = 15368

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

    "fried-shrimp" = {
      description    = "Your own personal AI assistant. Any OS. Any Platform. The lobster way. 🦞 "
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
          required_status_checks = [
            "call-common-markdownlint / markdownlint",
            "call-common-uv-qualify (3.11) / lint-and-test",
            "call-common-uv-qualify (3.12) / lint-and-test",
            "call-common-uv-qualify (3.13) / lint-and-test",
            "call-common-uv-qualify (3.14) / lint-and-test",
            "call-common-uv-qualify (3.11) / mypy",
            "call-common-uv-qualify (3.12) / mypy",
            "call-common-uv-qualify (3.13) / mypy",
            "call-common-uv-qualify (3.14) / mypy",
            "call-common-uv-qualify (3.11) / setup",
            "call-common-uv-qualify (3.12) / setup",
            "call-common-uv-qualify (3.13) / setup",
            "call-common-uv-qualify (3.14) / setup"
          ]
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
    }
  }
}
