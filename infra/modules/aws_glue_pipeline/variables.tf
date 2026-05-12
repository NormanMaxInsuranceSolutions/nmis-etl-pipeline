variable "name_prefix" {
  type        = string
  description = "Shared name prefix (e.g. nmis-dev)"
}

variable "pipeline_name" {
  type        = string
  description = "Short unique identifier for this pipeline (e.g. sf-to-snowflake). Used in all resource names."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags inherited from the root module"
}

variable "glue_role_arn" {
  type        = string
  description = "ARN of the shared Glue IAM execution role"
}

variable "scripts_bucket" {
  type        = string
  description = "Name of the shared S3 bucket for Glue scripts and temp data"
}

variable "script_local_path" {
  type        = string
  description = "Local filesystem path to the PySpark ETL script to upload"
}

variable "connections" {
  description = "Map of label to pre-created Glue connection name. Each key is auto-injected as --{key}_connection_name in job arguments."
  type        = map(string)
  default     = {}
}

variable "job_arguments" {
  description = "Additional --key=value arguments passed to the Glue job (merged with base args and auto-injected connection names)"
  type        = map(string)
  default     = {}
}

variable "glue_version" {
  type    = string
  default = "4.0"
}

variable "glue_worker_type" {
  type    = string
  default = "G.1X"
}

variable "glue_number_of_workers" {
  type    = number
  default = 2
}

variable "glue_job_timeout" {
  type        = number
  default     = 60
  description = "Job timeout in minutes"
}

variable "glue_max_retries" {
  type    = number
  default = 0
}

variable "glue_schedule" {
  type        = string
  default     = "cron(0 0 * * ? *)"
  description = "Cron schedule for the Glue trigger (used when trigger_type = SCHEDULED)"
}

variable "trigger_type" {
  type        = string
  default     = "SCHEDULED"
  description = "Glue trigger type: SCHEDULED or CONDITIONAL"

  validation {
    condition     = contains(["SCHEDULED", "CONDITIONAL"], var.trigger_type)
    error_message = "Must be SCHEDULED or CONDITIONAL."
  }
}

variable "trigger_predecessor_job" {
  type        = string
  default     = null
  description = "Name of the predecessor Glue job (required when trigger_type = CONDITIONAL)"
}