output "repositories" {
  description = "URLs of the base repositories"
  value       = { for name, repo in github_repository.base : name => repo.html_url }
}

output "platform_team" {
  description = "Slug of the platform team"
  value       = github_team.platform.slug
}
