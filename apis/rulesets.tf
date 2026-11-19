# Default-branch protection for every API repository.
# PoC deviation: 0 required approvals because the org has a single maintainer (production: >= 1, four-eyes).
resource "github_repository_ruleset" "main" {
  for_each = local.catalog

  name        = "main-protection"
  repository  = github_repository.api[each.key].name
  target      = "branch"
  enforcement = "active"

  # PoC: the single maintainer (platform-team) may merge own changes to code-owned files via PR only.
  # Production: remove this bypass and require >= 1 approval.
  bypass_actors {
    actor_id    = tonumber(data.github_team.platform.id)
    actor_type  = "Team"
    bypass_mode = "pull_request"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = false
      required_review_thread_resolution = true
    }

    required_status_checks {
      strict_required_status_checks_policy = false
      do_not_enforce_on_create             = true

      required_check {
        context        = "validate / lint"
        integration_id = 15368
      }
    }
  }
}
