provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket               = "nmis-terraform"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "nmis-etl-pipeline-workspaces"
    region               = "us-east-1"
  }
}

locals {
  name_prefix    = replace("${terraform.workspace}-${var.app_prefix}-${var.component}", "_", "-")
  tags = {
    "ENV"       = upper(terraform.workspace)
    "APP"       = upper(var.app)
    "COMPONENT" = upper(var.component)
  }
}

#############################
####    APPFLOW — IAM    ####
#############################

resource "aws_s3_bucket_policy" "data_lake_appflow" {
  bucket = aws_s3_bucket.data_lake.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "appflow.amazonaws.com" }
      Action = [
        "s3:PutObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts",
        "s3:ListBucketMultipartUploads",
        "s3:GetBucketAcl",
        "s3:PutObjectAcl"
      ]
      Resource = [
        aws_s3_bucket.data_lake.arn,
        "${aws_s3_bucket.data_lake.arn}/*"
      ]
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.aws_account
        }
      }
    }]
  })
}

##############################
####    SNOWPIPE — IAM    ####
##############################

resource "aws_iam_role" "snowflake_storage" {
  name = "${local.name_prefix}-snowflake-storage-role"
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = data.aws_ssm_parameter.snowflake_iam_user_arn.value }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = data.aws_ssm_parameter.snowflake_storage_external_id.value
        }
      }
    }]
  })
}

resource "aws_iam_policy" "snowflake_storage" {
  name = "${local.name_prefix}-snowflake-storage-policy"
  tags = local.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.data_lake.arn}/raw/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.data_lake.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_storage" {
  role       = aws_iam_role.snowflake_storage.name
  policy_arn = aws_iam_policy.snowflake_storage.arn
}

######################################
####    S3 — DATA LAKE BUCKET     ####
######################################

resource "aws_s3_bucket" "data_lake" {
  bucket = "${local.name_prefix}-data-lake"
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###############################################
####    APPFLOW — SALESFORCE Connection    ####
###############################################

resource "aws_secretsmanager_secret_policy" "salesforce_appflow_connector" {
  secret_arn = data.aws_secretsmanager_secret.salesforce_appflow_client_credentials.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "appflow.amazonaws.com" }
      Action    = "secretsmanager:GetSecretValue"
      Resource  = "*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.aws_account
        }
      }
    }]
  })
}

module "salesforce_connector" {
  source = "../modules/aws_appflow_connector"

  name           = "${local.name_prefix}-salesforce-connector"
  connector_type = "Salesforce"

  credentials = {
    salesforce = {
      access_token           = jsondecode(data.aws_secretsmanager_secret_version.salesforce_appflow_connector.secret_string)["accessToken"]
      refresh_token          = jsondecode(data.aws_secretsmanager_secret_version.salesforce_appflow_connector.secret_string)["refreshToken"]
      client_credentials_arn = data.aws_secretsmanager_secret.salesforce_appflow_client_credentials.arn
    }
  }

  properties = {
    salesforce = {
      instance_url           = data.aws_ssm_parameter.salesforce_instance_url.value
      is_sandbox_environment = data.aws_ssm_parameter.salesforce_environment.value == "SANDBOX"
    }
  }
}

########################
####    Pipelines   ####
########################

# —————————————————————————————————————————————————
# —— - Salesforce Policy -> Snowflake pipeline - ——
# —————————————————————————————————————————————————

# salesforce policy object -> S3 pipeline
module "salesforce_policy_to_s3" {
  source   = "../modules/aws_appflow_pipeline"
  name = "${local.name_prefix}-policy-sync"
  tags = local.tags

  source_connector_type         = "Salesforce"
  source_connector_profile_name = module.salesforce_connector.connector_profile_name
  source_config = {
    salesforce = { object = "Policy__c" }
  }

  incremental_pull_config = {
    datetime_type_field_name = "LastModifiedDate"
  }

  destination_connector_type = "S3"
  destination_config = {
    s3 = {
      bucket_name   = aws_s3_bucket.data_lake.bucket
      bucket_prefix = "raw/policy"
    }
  }

  trigger = {
    type = "Scheduled"
    scheduled = {
      schedule_expression = var.appflow_schedule
      data_pull_mode      = "Incremental"
    }
  }
}

resource "terraform_data" "activate_policy_flow" {
  triggers_replace = [module.salesforce_policy_to_s3.flow_arn]

  provisioner "local-exec" {
    command = "aws appflow start-flow --flow-name ${module.salesforce_policy_to_s3.flow_name} --region ${var.aws_region}"
  }
}

# S3 → Snowflake Snowpipe notifications
 resource "aws_s3_bucket_notification" "etl_snowpipes" {
    bucket      = aws_s3_bucket.data_lake.id
    eventbridge = true // enable event bridge

   // queue event for salesforce Policy object
   queue {
      id            = "${local.name_prefix}-policy-event"
      queue_arn     = data.aws_ssm_parameter.snowpipe_sqs_arn.value
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "raw/policy/"
      filter_suffix = ".parquet"
   }
 }
