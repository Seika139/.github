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
      description            = "GitHub上での共通設定を管理するためのリポジトリ"
      required_status_checks = ["markdownlint", "shellcheck", "yamllint", "mypy", "lint-and-test", "setup"]
      actions_secrets        = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
      dependabot_secrets     = ["PUSH_AND_RUN_WORKFLOW_TOKEN", "DOTENV_PRIVATE_KEY"]
    }
    # 他のリポジトリを追加する場合はここに追記
  }
}
