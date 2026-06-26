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
      description        = "LLMを利用した開発で得た知見をまとめる"
      visibility         = "private"
      has_wiki           = false
      default_branch     = "main"
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

    "twin-layer-brain-template" = {
      description    = "Template for twin-layer brain (SQLite fast search + LLM self-expanding wiki)"
      visibility     = "public"
      is_template    = true
      has_wiki       = false
      default_branch = "main"
      rulesets = {
        "main-protection" = {
          target                 = "branch"
          enforcement            = "active"
          include_refs           = ["~DEFAULT_BRANCH"]
          exclude_refs           = []
          deletion               = true
          non_fast_forward       = true
          required_status_checks = []
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "twin-layer-brain-personal" = {
      description    = "Personal-scope twin-layer-brain instance (general knowledge; work projects live in separate brains)"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      # 既存 private repo (claw-knowledge / second-brain) と同じく空定義にする。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "tlb-cats-eye" = {
      description    = "Personal-scope twin-layer-brain instance (for cats-eye developments)"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      # 既存 private repo (claw-knowledge / second-brain) と同じく空定義にする。
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
      description    = "外部依存ゼロの Discord Webhook クライアント（Python 標準ライブラリのみ）"
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
            "call-common-uv-qualify / setup",
            "call-common-uv-qualify / lint-and-test",
            "call-common-uv-qualify / mypy",
            "call-common-markdownlint / markdownlint",
          ]
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "repo-sync" = {
      description    = "ローカル git リポジトリを GitHub と自動同期する CLI（discord-notify 連携）"
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
            "call-common-uv-qualify / setup",
            "call-common-uv-qualify / lint-and-test",
            "call-common-uv-qualify / mypy",
            "call-common-markdownlint / markdownlint",
            "call-common-yamllint / yamllint",
            "call-common-shellcheck / shellcheck",
          ]
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "zipper" = {
      description    = "パスワードベースの暗号化 ZIP アーカイバ（ファイル名・ディレクトリ名の暗号化対応）"
      default_branch = "main"
      has_wiki       = false
      rulesets = {
        "main-protection" = {
          target                 = "branch"
          enforcement            = "active"
          include_refs           = ["~DEFAULT_BRANCH"]
          exclude_refs           = []
          deletion               = true
          non_fast_forward       = true
          required_status_checks = []
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "aws-cost-dashboard" = {
      description        = "AWS SSO 配下の複数アカウントのコストを可視化するローカルダッシュボード"
      default_branch     = "main"
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "ccusage-report" = {
      description    = "ccusage の JSON 出力をモデル別×日次に集計し、自己完結 HTML レポートを生成する個人ツール"
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
          # uv-qualify は python-version matrix ["3.13"] のため check 名に "(3.13)" が付く
          required_status_checks = [
            "call-common-uv-qualify (3.13) / setup",
            "call-common-uv-qualify (3.13) / lint-and-test",
            "call-common-uv-qualify (3.13) / mypy",
            "call-common-markdownlint / markdownlint",
            "call-common-yamllint / yamllint",
            "call-common-shellcheck / shellcheck",
          ]
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "tlb-investment" = {
      description    = "Personal-scope twin-layer-brain instance (for investment)"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "auto-invest" = {
      description    = ""
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "auto-invest-portfolio" = {
      description    = "auto-invest の運用状態 (現金 / 保有銘柄 / 取引ログ) を YAML で保持する private データリポジトリ"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = []
      dependabot_secrets = []
    }

    "airline-sale-monitor" = {
      description    = "航空会社の国内線セールを定期監視して Discord に通知する"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "web-change-monitor" = {
      description    = "指定した Web ページの特定領域の変更を定期監視して Discord に通知する"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "llm-runner" = {
      description    = "claude / codex を CLI または SDK 経由で headless 実行する薄いランナー"
      default_branch = "main"
      has_wiki       = false
      # CI 未導入のため zipper と同じ最小保護。CI 追加時に discord-notify 同等の
      # required_status_checks を設定する
      rulesets = {
        "main-protection" = {
          target                 = "branch"
          enforcement            = "active"
          include_refs           = ["~DEFAULT_BRANCH"]
          exclude_refs           = []
          deletion               = true
          non_fast_forward       = true
          required_status_checks = []
        }
      }
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }

    "alev" = {
      description    = "AI agent を 1 台のマシン上で定期的・常駐的に動かす control plane"
      visibility     = "private"
      has_wiki       = false
      default_branch = "main"
      # GitHub Free では private repo の ruleset は利用不可 (Pro 以上必要)。
      rulesets           = {}
      actions_secrets    = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
      dependabot_secrets = ["PUSH_AND_RUN_WORKFLOW_TOKEN"]
    }
  }
}
