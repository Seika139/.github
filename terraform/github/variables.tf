variable "DOTENV_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

variable "PUSH_AND_RUN_WORKFLOW_TOKEN" {
  type      = string
  sensitive = true
}

variable "github_actions_integration_id" {
  type    = number
  default = 15368
}
