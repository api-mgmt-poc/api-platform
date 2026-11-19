terraform {
  required_version = ">= 1.8.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }
}

# Authentication via the GITHUB_TOKEN environment variable (PoC: token of the org owner, local state).
provider "github" {
  owner = var.org
}
