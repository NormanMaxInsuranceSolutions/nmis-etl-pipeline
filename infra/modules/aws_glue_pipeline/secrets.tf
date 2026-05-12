# Secrets are managed by the aws_glue_connector module.
# Each connector with a secret_template gets a Secrets Manager secret
# created and linked automatically via the module.connector for_each.