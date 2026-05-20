# Salesforce — AppFlow connector
data "aws_ssm_parameter" "salesforce_instance_url" {
  name = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/salesforce_instance_url")
}

data "aws_ssm_parameter" "salesforce_environment" {
  name = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/salesforce_environment")
}

data "aws_secretsmanager_secret" "salesforce_appflow_connector" {
  name = "${terraform.workspace}/${var.app_prefix}/${var.component}/salesforce_appflow_connector"
}

data "aws_secretsmanager_secret" "salesforce_appflow_client_credentials" {
  name = "${terraform.workspace}/${var.app_prefix}/${var.component}/salesforce_appflow_client_credentials"
}

data "aws_secretsmanager_secret_version" "salesforce_appflow_connector" {
  secret_id = data.aws_secretsmanager_secret.salesforce_appflow_connector.id
}

# Snowflake
data "aws_ssm_parameter" "snowpipe_sqs_arn" {
  name = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/snowpipe_sqs_arn")
}

data "aws_ssm_parameter" "snowflake_iam_user_arn" {
  name = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/snowflake_iam_user_arn")
}

data "aws_ssm_parameter" "snowflake_storage_external_id" {
  name = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/snowflake_storage_external_id")
}
