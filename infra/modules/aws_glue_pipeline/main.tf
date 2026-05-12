locals {
  resource_prefix = "${var.name_prefix}-${var.pipeline_name}"
  catalog_db_name = replace(local.resource_prefix, "-", "_")
}

resource "aws_glue_catalog_database" "this" {
  name        = local.catalog_db_name
  description = "Glue data catalog for pipeline: ${var.pipeline_name}"
}

resource "aws_s3_object" "script" {
  bucket = var.scripts_bucket
  key    = "scripts/${var.pipeline_name}.py"
  source = var.script_local_path
  etag   = filemd5(var.script_local_path)
  tags   = var.tags
}


resource "aws_glue_job" "this" {
  name              = "${local.resource_prefix}-job"
  description       = "ETL pipeline: ${var.pipeline_name}"
  role_arn          = var.glue_role_arn
  glue_version      = var.glue_version
  worker_type       = var.glue_worker_type
  number_of_workers = var.glue_number_of_workers
  timeout           = var.glue_job_timeout
  max_retries       = var.glue_max_retries
  tags              = var.tags

  command {
    name            = "glueetl"
    script_location = "s3://${var.scripts_bucket}/${aws_s3_object.script.key}"
    python_version  = "3"
  }

  connections = values(var.connections)

  default_arguments = merge(
    {
      "--job-language"                     = "python"
      "--enable-metrics"                   = "true"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-job-insights"              = "true"
      "--job-bookmark-option"              = "job-bookmark-enable"
      "--TempDir"                          = "s3://${var.scripts_bucket}/tmp/${var.pipeline_name}/"
    },
    { for k, name in var.connections : "--${k}_connection_name" => name },
    var.job_arguments,
  )
}

resource "aws_glue_trigger" "scheduled" {
  count    = var.trigger_type == "SCHEDULED" ? 1 : 0
  name     = "${local.resource_prefix}-trigger"
  type     = "SCHEDULED"
  schedule = var.glue_schedule
  tags     = var.tags

  actions {
    job_name = aws_glue_job.this.name
  }
}

resource "aws_glue_trigger" "conditional" {
  count = var.trigger_type == "CONDITIONAL" ? 1 : 0
  name  = "${local.resource_prefix}-trigger"
  type  = "CONDITIONAL"
  tags  = var.tags

  actions {
    job_name = aws_glue_job.this.name
  }

  predicate {
    conditions {
      job_name = var.trigger_predecessor_job
      state    = "SUCCEEDED"
    }
  }
}