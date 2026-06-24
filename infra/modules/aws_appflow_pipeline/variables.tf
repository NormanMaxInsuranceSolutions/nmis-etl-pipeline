variable "name" {
  type        = string
  description = "Name of the AppFlow flow"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

############################
##  Source configuration  ##
############################

variable "source_connector_type" {
  type        = string
  description = "AppFlow source connector type (e.g. Salesforce, Zendesk, ServiceNow, S3)"
}

variable "source_connector_profile_name" {
  type        = string
  default     = null
  description = "AppFlow connector profile name for the source (not required for native AWS sources like S3)"
}

variable "source_config" {
  description = "Source connector properties — populate only the block matching source_connector_type"
  type = object({
    salesforce = optional(object({
      object                      = string
      enable_dynamic_field_update = optional(bool, true)
      include_deleted_records     = optional(bool, true)
    }))
    zendesk = optional(object({
      object = string
    }))
    service_now = optional(object({
      object = string
    }))
    slack = optional(object({
      object = string
    }))
    s3 = optional(object({
      bucket_name   = string
      bucket_prefix = optional(string)
    }))
  })
}

variable "incremental_pull_config" {
  type = object({
    datetime_type_field_name = string
  })
  default     = null
  description = "Field used as the incremental pull watermark. Set to null for full refresh."
}

#################################
##  Destination configuration  ##
#################################

variable "destination_connector_type" {
  type        = string
  description = "AppFlow destination connector type (e.g. S3, Redshift, Snowflake, EventBridge)"
}

variable "destination_connector_profile_name" {
  type        = string
  default     = null
  description = "AppFlow connector profile name for the destination (not required for native AWS destinations like S3)"
}

variable "destination_config" {
  description = "Destination connector properties — populate only the block matching destination_connector_type"
  type = object({
    s3 = optional(object({
      bucket_name      = string
      bucket_prefix    = optional(string)
      file_type        = optional(string, "PARQUET")
      aggregation_type = optional(string, "None")
      prefix_type      = optional(string, "PATH")
      prefix_format    = optional(string, "HOUR")
    }))
    redshift = optional(object({
      object             = string
      intermediate_bucket_name = string
      bucket_prefix      = optional(string)
    }))
    event_bridge = optional(object({
      object = string
      error_handling_config = optional(object({
        fail_on_first_destination_error = optional(bool, true)
        bucket_name                     = optional(string)
        bucket_prefix                   = optional(string)
      }))
    }))
  })
}

#############################
##  Trigger configuration  ##
#############################

variable "trigger" {
  description = "Flow trigger configuration"
  type = object({
    type = string
    scheduled = optional(object({
      schedule_expression = string
      data_pull_mode      = optional(string, "Incremental")
    }))
  })
  default = {
    type = "Scheduled"
    scheduled = {
      schedule_expression = "rate(5 minutes)"
    }
  }
}

##############################
##  Notification configuration  ##
##############################

variable "enable_error_notifications" {
  type        = bool
  default     = true
  description = "Create an SNS topic and EventBridge rule to publish a message when the flow execution fails"
}

variable "chatbot_alerts_topic_arn" {
  type        = string
  default     = null
  description = "ARN of the shared chatbot SNS alerts topic. When set, EventBridge will also publish failures there alongside the per-pipeline topic."
}