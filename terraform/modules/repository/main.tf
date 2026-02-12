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

variable "homepage_url" {
  type        = string
  description = "The URL of a page related to the repository."
  default     = ""
}

variable "default_branch" {
  type        = string
  description = "The default branch of the repository."
  default     = "main"
}

variable "rulesets" {
  type = map(object({
    target           = string
    enforcement      = string
    include_refs     = list(string)
    exclude_refs     = list(string)
    deletion         = bool
    non_fast_forward = bool
    pull_request = optional(object({
      required_approving_review_count   = number
      required_review_thread_resolution = bool
      dismiss_stale_reviews_on_push     = bool
    }), null)
    required_status_checks = list(string)
    bypass_actors = optional(list(object({
      actor_id    = number
      actor_type  = string
      bypass_mode = string
    })), [])
  }))
  description = "A map of rulesets to apply to the repository."
  default     = {}
}

variable "actions_secrets" {
  type        = map(string)
  description = "A map of secrets to set for GitHub Actions."
  default     = {}
  sensitive   = true
}

variable "dependabot_secrets" {
  type        = map(string)
  description = "A map of secrets to set for Dependabot."
  default     = {}
  sensitive   = true
}

variable "integration_id" {
  type        = number
  description = "The integration ID for GitHub Actions or other apps."
  default     = 15368
}

resource "github_repository" "repo" {
  name                   = var.name
  description            = var.description
  homepage_url           = var.homepage_url
  delete_branch_on_merge = true
  allow_update_branch    = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  vulnerability_alerts   = true
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = var.default_branch
}

resource "github_repository_ruleset" "this" {
  for_each    = var.rulesets
  name        = each.key
  repository  = github_repository.repo.name
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = each.value.include_refs
      exclude = each.value.exclude_refs
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    deletion         = each.value.deletion
    non_fast_forward = each.value.non_fast_forward

    dynamic "pull_request" {
      for_each = each.value.pull_request != null ? [each.value.pull_request] : []
      content {
        required_approving_review_count   = pull_request.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }

    dynamic "required_status_checks" {
      for_each = length(each.value.required_status_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = true
        dynamic "required_check" {
          for_each = each.value.required_status_checks
          content {
            context        = required_check.value
            integration_id = var.integration_id
          }
        }
      }
    }
  }
}

resource "github_actions_secret" "this" {
  for_each        = nonsensitive(toset(keys(var.actions_secrets)))
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = var.actions_secrets[each.key]
}

resource "github_dependabot_secret" "this" {
  for_each        = nonsensitive(toset(keys(var.dependabot_secrets)))
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = var.dependabot_secrets[each.key]
}
