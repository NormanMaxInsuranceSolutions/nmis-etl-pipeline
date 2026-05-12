resource "aws_appflow_connector_profile" "this" {
  name            = var.name
  connector_type  = var.connector_type
  connection_mode = var.connection_mode

  connector_profile_config {
    connector_profile_credentials {
      dynamic "salesforce" {
        for_each = var.credentials.salesforce != null ? [var.credentials.salesforce] : []
        content {
          access_token           = salesforce.value.access_token
          jwt_token              = salesforce.value.jwt_token
          refresh_token          = salesforce.value.refresh_token
          client_credentials_arn = salesforce.value.client_credentials_arn
        }
      }
      dynamic "zendesk" {
        for_each = var.credentials.zendesk != null ? [var.credentials.zendesk] : []
        content {
          access_token  = zendesk.value.access_token
          client_id     = zendesk.value.client_id
          client_secret = zendesk.value.client_secret
        }
      }
      dynamic "service_now" {
        for_each = var.credentials.service_now != null ? [var.credentials.service_now] : []
        content {
          username = service_now.value.username
          password = service_now.value.password
        }
      }
      dynamic "slack" {
        for_each = var.credentials.slack != null ? [var.credentials.slack] : []
        content {
          access_token  = slack.value.access_token
          client_id     = slack.value.client_id
          client_secret = slack.value.client_secret
        }
      }
    }

    connector_profile_properties {
      dynamic "salesforce" {
        for_each = var.properties.salesforce != null ? [var.properties.salesforce] : []
        content {
          instance_url           = salesforce.value.instance_url
          is_sandbox_environment = salesforce.value.is_sandbox_environment
        }
      }
      dynamic "zendesk" {
        for_each = var.properties.zendesk != null ? [var.properties.zendesk] : []
        content {
          instance_url = zendesk.value.instance_url
        }
      }
      dynamic "service_now" {
        for_each = var.properties.service_now != null ? [var.properties.service_now] : []
        content {
          instance_url = service_now.value.instance_url
        }
      }
      dynamic "slack" {
        for_each = var.properties.slack != null ? [var.properties.slack] : []
        content {
          instance_url = slack.value.instance_url
        }
      }
    }
  }
}