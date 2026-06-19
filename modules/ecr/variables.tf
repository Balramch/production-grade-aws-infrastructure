variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "repositories" {
  description = "Map of ECR repositories to create with their configuration"
  type = map(object({
    name                    = string
    enable_image_scan       = optional(bool, true)
    scan_on_push            = optional(bool, true)
    encryption_type         = optional(string, "AES256") # AES256 or KMS
    kms_key_id              = optional(string, null)
    image_tag_mutability    = optional(string, "MUTABLE") # MUTABLE or IMMUTABLE
    image_retention_days    = optional(number, 30)
    enable_repository_policy = optional(bool, false)
    repository_policy_json  = optional(string, "")
    tags                    = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "registry_scan_config" {
  description = "Registry-level scan configuration"
  type = object({
    scan_type   = optional(string, "BASIC")
    rules       = optional(list(string), [])
  })
  default = {}
}

variable "enable_lifecycle_policy" {
  description = "Enable automatic image retention and cleanup policies"
  type        = bool
  default     = true
}

variable "default_image_retention_count" {
  description = "Default number of images to retain per repository"
  type        = number
  default     = 10
}
