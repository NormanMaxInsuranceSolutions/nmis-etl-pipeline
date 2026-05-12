variable "name" {
  type        = string
  description = "Name of the AppFlow connector profile"
}

variable "connector_type" {
  type        = string
  description = "AppFlow connector type (e.g. Salesforce, Zendesk, ServiceNow, Slack)"
}

variable "connection_mode" {
  type        = string
  default     = "Public"
  description = "AppFlow connection mode: Public or Private"
}

variable "credentials" {
  sensitive   = true
  description = "Connector-specific credentials — populate only the block matching connector_type"
  type = object({
    salesforce = optional(object({
      access_token           = optional(string)
      jwt_token              = optional(string)
      refresh_token          = optional(string)
      client_credentials_arn = optional(string)
    }))
    zendesk = optional(object({
      access_token  = optional(string)
      client_id     = optional(string)
      client_secret = optional(string)
    }))
    service_now = optional(object({
      username = string
      password = string
    }))
    slack = optional(object({
      access_token  = optional(string)
      client_id     = optional(string)
      client_secret = optional(string)
    }))
  })
}

variable "properties" {
  description = "Connector-specific connection properties — populate only the block matching connector_type"
  type = object({
    salesforce = optional(object({
      instance_url           = string
      is_sandbox_environment = optional(bool, false)
    }))
    zendesk = optional(object({
      instance_url = string
    }))
    service_now = optional(object({
      instance_url = string
    }))
    slack = optional(object({
      instance_url = string
    }))
  })
  default = {}
}