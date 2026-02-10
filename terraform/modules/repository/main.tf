terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "name" {
  type        = string
  description = "The name of the repository."
}

variable "description" {
  type        = string
  description = "A description of the repository."
  default     = ""
}

variable "required_status_checks" {
  type        = list(string)
  description = "A list of required status checks for the main branch ruleset."
  default     = []
}

variable "actions_secrets" {
  type        = map(string)
  description = "A map of secrets to set for GitHub Actions."
  default     = {}
}

variable "dependabot_secrets" {
  type        = map(string)
  description = "A map of secrets to set for Dependabot."
  default     = {}
}

resource "github_repository" "repo" {
  name                   = var.name
  description            = var.description
  delete_branch_on_merge = true
  allow_update_branch    = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  vulnerability_alerts   = true
}

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
    deletion         = true
    non_fast_forward = true

    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = true
      require_code_owner_review         = false
      require_last_push_approval        = false
    }

    dynamic "required_status_checks" {
      for_each = length(var.required_status_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = true
        dynamic "required_check" {
          for_each = var.required_status_checks
          content {
            context        = required_check.value
            integration_id = 15368
          }
        }
      }
    }
  }
}

resource "github_actions_secret" "this" {
  for_each        = var.actions_secrets
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_dependabot_secret" "this" {
  for_each        = var.dependabot_secrets
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}
