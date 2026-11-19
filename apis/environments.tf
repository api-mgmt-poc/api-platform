# Stages are environments, not branches. Only main may deploy; prod needs an approval.
# PoC deviation: prevent_self_review = false because the org has a single person (production: true).
resource "github_repository_environment" "dev" {
  for_each = local.catalog

  repository          = github_repository.api[each.key].name
  environment         = "dev"
  can_admins_bypass   = false
  prevent_self_review = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment" "prod" {
  for_each = local.catalog

  repository          = github_repository.api[each.key].name
  environment         = "prod"
  can_admins_bypass   = false
  prevent_self_review = false

  reviewers {
    users = [tonumber(data.github_user.prod_reviewer.id)]
  }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "dev_main" {
  for_each = local.catalog

  repository     = github_repository.api[each.key].name
  environment    = github_repository_environment.dev[each.key].environment
  branch_pattern = "main"
}

resource "github_repository_environment_deployment_policy" "prod_main" {
  for_each = local.catalog

  repository     = github_repository.api[each.key].name
  environment    = github_repository_environment.prod[each.key].environment
  branch_pattern = "main"
}

resource "github_actions_environment_variable" "backend_dev" {
  for_each = local.catalog

  repository    = github_repository.api[each.key].name
  environment   = github_repository_environment.dev[each.key].environment
  variable_name = "BACKEND_BASEPATH"
  value         = each.value.backend_url_dev
}

resource "github_actions_environment_variable" "backend_prod" {
  for_each = local.catalog

  repository    = github_repository.api[each.key].name
  environment   = github_repository_environment.prod[each.key].environment
  variable_name = "BACKEND_BASEPATH"
  value         = each.value.backend_url_prod
}
