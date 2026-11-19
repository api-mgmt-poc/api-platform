variable "org" {
  description = "GitHub organization of the PoC"
  type        = string
  default     = "api-mgmt-poc"
}

variable "catalog_dir" {
  description = "Absolute path of the apis/ folder in a freshly pulled api-catalog checkout"
  type        = string

  validation {
    condition     = startswith(var.catalog_dir, "/") && fileexists("${var.catalog_dir}/.gitkeep")
    error_message = "catalog_dir must be the absolute path of the apis/ folder of an api-catalog checkout."
  }
}

variable "template_repo" {
  description = "Template repository for new API repositories"
  type        = string
  default     = "api-template"
}

variable "prod_reviewer" {
  description = "GitHub user who approves prod deployments (pass via TF_VAR_prod_reviewer)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,37}[A-Za-z0-9])?$", var.prod_reviewer))
    error_message = "prod_reviewer must be a valid GitHub user name."
  }
}
