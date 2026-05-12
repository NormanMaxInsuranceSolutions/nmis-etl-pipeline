variable "name" {
  type        = string
  description = "Full Glue connection resource name"
}

variable "connection_type" {
  type        = string
  description = "Glue connection type (SALESFORCE, JDBC, MONGODB, KAFKA, NETWORK, etc.)"
}

variable "connection_properties" {
  type        = map(string)
  description = "Glue connection properties for the given type. Do not include SECRET_ID — it is injected automatically when secret_name is set."
  default     = {}
}

variable "description" {
  type        = string
  description = "Human-readable description of the connection"
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
}

# Networking — omit subnet_id to skip physical_connection_requirements entirely
# (useful for connection types that do not require VPC access)
variable "subnet_id" {
  type        = string
  description = "Subnet ID for the connection. Leave null to omit physical_connection_requirements."
  default     = null
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the connection. Required when subnet_id is set."
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for the connection. Required when subnet_id is set."
  default     = []
}

# Secret — omit to manage credentials outside this module
variable "secret_name" {
  type        = string
  description = "Secrets Manager secret name. When set, a secret is created and SECRET_ID is injected into connection_properties."
  default     = null
}

variable "secret_description" {
  type        = string
  description = "Description for the Secrets Manager secret"
  default     = ""
}

variable "secret_template" {
  type        = map(string)
  description = "Initial key/value structure written to the secret on creation. Values are placeholder strings — populate real credentials after apply."
  default     = null
}