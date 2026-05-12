######################################
####    ETL PIPELINE SSM OUTPUTS  ####
######################################

resource "aws_ssm_parameter" "salesforce_secret_arn" {
  name  = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/salesforce_secret_arn")
  type  = "String"
  value = data.aws_secretsmanager_secret.salesforce_appflow_connector.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "data_lake_bucket" {
  name  = upper("/${var.app_prefix}/${terraform.workspace}/${var.component}/data_lake_bucket")
  type  = "String"
  value = aws_s3_bucket.data_lake.bucket
  tags  = local.tags
}

