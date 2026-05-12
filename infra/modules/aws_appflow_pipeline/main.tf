resource "aws_appflow_flow" "this" {
  name = var.name
  tags = var.tags

  source_flow_config {
    connector_type         = var.source_connector_type
    connector_profile_name = var.source_connector_profile_name

    dynamic "source_connector_properties" {
      for_each = [1]
      content {
        dynamic "salesforce" {
          for_each = var.source_config.salesforce != null ? [var.source_config.salesforce] : []
          content {
            object                      = salesforce.value.object
            enable_dynamic_field_update = salesforce.value.enable_dynamic_field_update
            include_deleted_records     = salesforce.value.include_deleted_records
          }
        }
        dynamic "zendesk" {
          for_each = var.source_config.zendesk != null ? [var.source_config.zendesk] : []
          content {
            object = zendesk.value.object
          }
        }
        dynamic "service_now" {
          for_each = var.source_config.service_now != null ? [var.source_config.service_now] : []
          content {
            object = service_now.value.object
          }
        }
        dynamic "slack" {
          for_each = var.source_config.slack != null ? [var.source_config.slack] : []
          content {
            object = slack.value.object
          }
        }
        dynamic "s3" {
          for_each = var.source_config.s3 != null ? [var.source_config.s3] : []
          content {
            bucket_name   = s3.value.bucket_name
            bucket_prefix = s3.value.bucket_prefix
          }
        }
      }
    }

    dynamic "incremental_pull_config" {
      for_each = var.incremental_pull_config != null ? [var.incremental_pull_config] : []
      content {
        datetime_type_field_name = incremental_pull_config.value.datetime_type_field_name
      }
    }
  }

  destination_flow_config {
    connector_type         = var.destination_connector_type
    connector_profile_name = var.destination_connector_profile_name

    dynamic "destination_connector_properties" {
      for_each = [1]
      content {
        dynamic "s3" {
          for_each = var.destination_config.s3 != null ? [var.destination_config.s3] : []
          content {
            bucket_name   = s3.value.bucket_name
            bucket_prefix = s3.value.bucket_prefix

            s3_output_format_config {
              file_type = s3.value.file_type

              aggregation_config {
                aggregation_type = s3.value.aggregation_type
              }

              prefix_config {
                prefix_type   = s3.value.prefix_type
                prefix_format = s3.value.prefix_format
              }
            }
          }
        }
        dynamic "redshift" {
          for_each = var.destination_config.redshift != null ? [var.destination_config.redshift] : []
          content {
            object                   = redshift.value.object
            intermediate_bucket_name = redshift.value.intermediate_bucket_name
            bucket_prefix            = redshift.value.bucket_prefix
          }
        }
        dynamic "event_bridge" {
          for_each = var.destination_config.event_bridge != null ? [var.destination_config.event_bridge] : []
          content {
            object = event_bridge.value.object

            dynamic "error_handling_config" {
              for_each = event_bridge.value.error_handling_config != null ? [event_bridge.value.error_handling_config] : []
              content {
                fail_on_first_destination_error = error_handling_config.value.fail_on_first_destination_error
                bucket_name                     = error_handling_config.value.bucket_name
                bucket_prefix                   = error_handling_config.value.bucket_prefix
              }
            }
          }
        }
      }
    }
  }

  trigger_config {
    trigger_type = var.trigger.type

    dynamic "trigger_properties" {
      for_each = var.trigger.scheduled != null ? [var.trigger.scheduled] : []
      content {
        scheduled {
          schedule_expression = trigger_properties.value.schedule_expression
          data_pull_mode      = trigger_properties.value.data_pull_mode
        }
      }
    }
  }

  task {
    task_type     = "Map_all"
    source_fields = []
    connector_operator {
      salesforce  = var.source_connector_type == "Salesforce" ? "NO_OP" : null
      zendesk     = var.source_connector_type == "Zendesk" ? "NO_OP" : null
      service_now = var.source_connector_type == "ServiceNow" ? "NO_OP" : null
      slack       = var.source_connector_type == "Slack" ? "NO_OP" : null
      s3          = var.source_connector_type == "S3" ? "NO_OP" : null
    }
  }
}