variable "DOTENV_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

variable "PUSH_AND_RUN_WORKFLOW_TOKEN" {
  type      = string
  sensitive = true
}

variable "github_repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository (e.g., 'owner/repo')."
  default     = ""
}
