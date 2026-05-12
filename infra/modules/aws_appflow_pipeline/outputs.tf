output "flow_name" {
  description = "Name of the AppFlow flow"
  value       = aws_appflow_flow.this.name
}

output "flow_arn" {
  description = "ARN of the AppFlow flow"
  value       = aws_appflow_flow.this.arn
}
