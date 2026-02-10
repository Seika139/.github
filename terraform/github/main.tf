# module を利用してリポジトリを一括管理
module "repository" {
  source   = "../modules/repository"
  for_each = local.repositories

  name                   = each.key
  description            = each.value.description
  required_status_checks = each.value.required_status_checks

  actions_secrets = {
    for s in each.value.actions_secrets : s => local.secret_values[s]
  }

  dependabot_secrets = {
    for s in each.value.dependabot_secrets : s => local.secret_values[s]
  }
}

# --- 構成移行用の設定 (moved blocks) ---
# これにより、既存の設定が削除・再作成されるのを防ぎ、新しい構成に「移動」したとみなされます。

moved {
  from = github_repository.repo
  to   = module.repository[".github"].github_repository.repo
}

moved {
  from = github_repository_ruleset.main
  to   = module.repository[".github"].github_repository_ruleset.main
}

moved {
  from = github_actions_secret.this
  to   = module.repository[".github"].github_actions_secret.this
}

moved {
  from = github_dependabot_secret.dependabot
  to   = module.repository[".github"].github_dependabot_secret.this
}
