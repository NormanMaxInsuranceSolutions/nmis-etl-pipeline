output "flow_name" {
  description = "Name of the AppFlow flow"
  value       = aws_appflow_flow.this.name
}

output "flow_arn" {
  description = "ARN of the AppFlow flow"
  value       = aws_appflow_flow.this.arn
}

output "error_topic_arn" {
  description = "ARN of the SNS error notification topic (null if error notifications are disabled)"
  value       = var.enable_error_notifications ? aws_sns_topic.error[0].arn : null
}
