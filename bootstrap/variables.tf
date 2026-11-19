variable "org" {
  description = "GitHub organization of the PoC"
  type        = string
  default     = "api-mgmt-poc"
}

variable "platform_maintainer" {
  description = "GitHub user who maintains the platform team (pass via TF_VAR_platform_maintainer)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,37}[A-Za-z0-9])?$", var.platform_maintainer))
    error_message = "platform_maintainer must be a valid GitHub user name."
  }
}

variable "enable_rulesets" {
  description = "Create branch rulesets. Only the very first bootstrap of an empty org runs with false (see README)."
  type        = bool
  default     = true
}
