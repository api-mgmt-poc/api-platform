# One repository per catalog entry (apis/<api_name>.json), created from the API template.
locals {
  catalog = {
    for file in fileset(var.catalog_dir, "*.json") :
    trimsuffix(file, ".json") => jsondecode(file("${var.catalog_dir}/${file}"))
  }
  owner_groups = toset([for api in local.catalog : api.owner_group])
}

data "github_team" "platform" {
  slug = "platform-team"
}

data "github_repository_file" "template_ci" {
  repository = var.template_repo
  file       = ".github/workflows/ci.yml"
}

data "github_user" "prod_reviewer" {
  username = var.prod_reviewer
}

resource "github_repository" "api" {
  for_each = local.catalog

  name                   = "api-${each.value.api_name}"
  description            = "${substr(each.value.description, 0, 200)} (${each.value.servicenow_ritm})"
  visibility             = "public"
  topics                 = ["api", "data-${each.value.data_class}"]
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  archive_on_destroy     = true

  template {
    owner      = var.org
    repository = var.template_repo
  }

  lifecycle {
    precondition {
      condition = (
        each.key == each.value.api_name
        && can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", each.value.api_name))
        && can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", each.value.owner_group))
        && contains(["internal", "confidential"], each.value.data_class)
      )
      error_message = "Catalog entry is invalid: file name must equal api_name and all fields must match the catalog rules."
    }

    precondition {
      condition     = !contains(["catalog", "template", "platform"], each.value.api_name) && each.value.owner_group != "platform-team"
      error_message = "api_name or owner_group collides with a platform repository or team."
    }

    precondition {
      condition     = can(regex("api-validate\\.yml@[0-9a-f]{40}", data.github_repository_file.template_ci.content))
      error_message = "The template has no CI workflow pinned to a full commit SHA yet; push the template content first."
    }
  }
}

resource "github_team" "owner" {
  for_each = local.owner_groups

  name        = each.key
  description = "API owner team (from ServiceNow onboarding)"
  privacy     = "closed"
}

resource "github_team_repository" "owner" {
  for_each = local.catalog

  team_id    = github_team.owner[each.value.owner_group].id
  repository = github_repository.api[each.key].name
  permission = "push"
}

resource "github_team_repository" "platform" {
  for_each = local.catalog

  team_id    = data.github_team.platform.id
  repository = github_repository.api[each.key].name
  permission = "maintain"
}

resource "github_repository_vulnerability_alerts" "api" {
  for_each = github_repository.api

  repository = each.value.name
  enabled    = true
}
