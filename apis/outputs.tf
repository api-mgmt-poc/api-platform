output "api_repositories" {
  description = "Created API repositories with their ServiceNow request numbers"
  value = {
    for name, repo in github_repository.api :
    name => { url = repo.html_url, ritm = local.catalog[name].servicenow_ritm }
  }
}
