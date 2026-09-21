variable "DOTENV_PRIVATE_KEY" {
  type      = string
  sensitive = true

  validation {
    condition     = length(trimspace(var.DOTENV_PRIVATE_KEY)) > 0
    error_message = "DOTENV_PRIVATE_KEY must not be empty (see 2026-09-15 incident: empty value overwrote GitHub secrets)."
  }
}

variable "PUSH_AND_RUN_WORKFLOW_TOKEN" {
  type      = string
  sensitive = true

  validation {
    condition     = length(trimspace(var.PUSH_AND_RUN_WORKFLOW_TOKEN)) > 0
    error_message = "PUSH_AND_RUN_WORKFLOW_TOKEN must not be empty (see 2026-09-15 incident: empty value overwrote GitHub secrets)."
  }
}

variable "github_actions_integration_id" {
  type    = number
  default = 15368
}
