variable "aws_account" {
  type    = string
  default = "851725482801"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app" {
  type    = string
  default = "normanmax"
}

variable "app_prefix" {
  type    = string
  default = "nmis"
}

variable "component" {
  type    = string
  default = "etl_pipelines"
}

variable "appflow_schedule" {
  type        = string
  default     = "rate(5 minutes)"
  description = "AppFlow schedule expression (e.g. rate(5 minutes), rate(1 hours))"
}