resource "aws_glue_connection" "this" {
  name            = var.name
  connection_type = var.connection_type
  description     = var.description
  tags            = var.tags

  connection_properties = merge(
    var.connection_properties,
    var.secret_name != null ? { SECRET_ID = aws_secretsmanager_secret.this[0].arn } : {}
  )

  dynamic "physical_connection_requirements" {
    for_each = var.subnet_id != null ? [1] : []
    content {
      availability_zone      = var.availability_zone
      security_group_id_list = var.security_group_ids
      subnet_id              = var.subnet_id
    }
  }
}