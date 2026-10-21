terraform {
  cloud {
    organization = "seika139-github"

    workspaces {
      name = "github-repositories"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.12.0, < 7.0.0"
    }
  }
}

provider "github" {}
