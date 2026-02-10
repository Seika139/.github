# module を利用してリポジトリを一括管理
module "repository" {
  source   = "../modules/repository"
  for_each = local.repositories

  name           = each.key
  description    = each.value.description
  homepage_url   = try(each.value.homepage_url, "")
  default_branch = try(each.value.default_branch, "main")
  rulesets       = each.value.rulesets

  actions_secrets = {
    for s in each.value.actions_secrets : s => local.secret_values[s]
  }

  dependabot_secrets = {
    for s in each.value.dependabot_secrets : s => local.secret_values[s]
  }
}
