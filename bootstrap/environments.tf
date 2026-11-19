# Environment holding the ServiceNow credentials of api-catalog; only main may use it.
resource "github_repository_environment" "servicenow" {
  repository          = github_repository.base["api-catalog"].name
  environment         = "servicenow"
  can_admins_bypass   = false
  prevent_self_review = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "servicenow_main" {
  repository     = github_repository.base["api-catalog"].name
  environment    = github_repository_environment.servicenow.environment
  branch_pattern = "main"
}
