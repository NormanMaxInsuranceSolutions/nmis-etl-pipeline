output "connection_name" {
  description = "Name of the Glue connection"
  value       = aws_glue_connection.this.name
}

output "connection_id" {
  description = "ID of the Glue connection"
  value       = aws_glue_connection.this.id
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret, or null if no secret was created"
  value       = var.secret_name != null ? aws_secretsmanager_secret.this[0].arn : null
  sensitive   = true
}