# api-platform

OpenTofu code of the API platform (PoC). State is local in the PoC; production needs a remote backend with locking.

| Module | Creates |
|---|---|
| `bootstrap/` | base repositories (workflow-templates, api-template, api-catalog, api-platform), platform team, environment `servicenow` (main only) in api-catalog, rulesets |
| `apis/` | one repository per catalog entry from the template: owner team, environments dev/prod (main only, prod approval), backend URL per environment, ruleset with required check `validate / lint` and code-owner review |

## Run (PoC, locally)

```bash
export GITHUB_TOKEN="$(gh auth token)"
export TF_VAR_platform_maintainer=<github-user> TF_VAR_prod_reviewer=<github-user>

# 1. First bootstrap of an empty org only: create repositories without rulesets
tofu -chdir=bootstrap init && tofu -chdir=bootstrap apply -var enable_rulesets=false
# 2. Push the initial content: workflow-templates first, then api-template with that commit SHA, then the rest
#    (github/push-repo.sh in the PoC repository)
# 3. Every later run: plain apply (rulesets are on by default and are never removed by accident)
tofu -chdir=bootstrap apply
# 4. API repositories from the catalog (absolute path to a freshly pulled checkout)
git -C <checkout>/api-catalog pull --ff-only
tofu -chdir=apis init && tofu -chdir=apis apply -var catalog_dir=<absolute-path>/api-catalog/apis
```

## Guards
- `catalog_dir` must be an absolute path containing `.gitkeep`; a wrong path fails instead of planning to archive every API repository
- `apis` refuses to run until `api-template` has a CI workflow pinned to a full commit SHA
- Reserved names (`catalog`, `template`, `platform`, team `platform-team`) are rejected

## PoC deviations and residual risks
- Single person: 0 required approvals, `prevent_self_review = false`, platform team may bypass rulesets **via pull request only** (recorded). Production: >= 1 approval, self-review prevented, no bypass.
- Required check `validate / lint` is pinned to the GitHub Actions app (id 15368). A writer could still post a passing check run from a workflow on an unmerged branch. Fully closing this needs an org-level "require workflows to pass" ruleset (GitHub Team/Enterprise) or a check reported by a dedicated GitHub App.
- State is local and not encrypted; production: remote backend (e.g. HCP Terraform or S3 with locking) and OpenTofu state encryption.
