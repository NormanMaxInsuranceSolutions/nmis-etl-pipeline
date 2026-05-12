output "job_name" {
  description = "Name of the Glue ETL job"
  value       = aws_glue_job.this.name
}

output "trigger_name" {
  description = "Name of the Glue scheduled trigger"
  value       = aws_glue_trigger.daily.name
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.this.name
}
