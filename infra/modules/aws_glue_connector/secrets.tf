resource "aws_secretsmanager_secret" "this" {
  count       = var.secret_name != null ? 1 : 0
  name        = var.secret_name
  description = var.secret_description
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.secret_name != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode(coalesce(var.secret_template, {}))

  lifecycle {
    ignore_changes = [secret_string]
  }
}