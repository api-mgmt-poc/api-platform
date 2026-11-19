locals {
  base_repos = {
    "workflow-templates" = { description = "Central reusable workflows of the API platform (PoC)", is_template = false }
    "api-template"       = { description = "Template for new API repositories (PoC)", is_template = true }
    "api-catalog"        = { description = "API onboarding catalog fed by ServiceNow (PoC)", is_template = false }
    "api-platform"       = { description = "OpenTofu code that provisions API repositories (PoC)", is_template = false }
  }

  # Required checks per repository; reported by the GitHub Actions app (id 15368).
  required_checks = {
    "api-template" = ["validate / lint"]
    "api-catalog"  = ["validate-entries"]
  }
}

resource "github_team" "platform" {
  name        = "platform-team"
  description = "Owns the API platform, reusable workflows and templates"
  privacy     = "closed"
}

resource "github_team_membership" "platform_maintainer" {
  team_id  = github_team.platform.id
  username = var.platform_maintainer
  role     = "maintainer"
}

resource "github_repository" "base" {
  for_each = local.base_repos

  name                   = each.key
  description            = each.value.description
  visibility             = "public"
  is_template            = each.value.is_template
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
}

resource "github_team_repository" "platform" {
  for_each = github_repository.base

  team_id    = github_team.platform.id
  repository = each.value.name
  permission = "maintain"
}

resource "github_repository_vulnerability_alerts" "base" {
  for_each = github_repository.base

  repository = each.value.name
  enabled    = true
}
