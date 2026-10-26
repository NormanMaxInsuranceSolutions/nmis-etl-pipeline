# nmis-etl-pipeline
Terraform configuration for AWS data Extraction, Transformation, and Loading pipelines managed by NormanMax Insurance Solutions

## Warning: AppFlow flows with explicit field mappings
A flow can pass `tasks` with a fixed list of fields instead of mapping all fields (see `infra/terraform/flows/*.tasks.json`). That list is used as-is in dev (Salesforce arch), uat and prod, so:
- Every field must exist with the same API name in all three Salesforce orgs.
- The AppFlow integration user must be able to read every field, and the objects its lookup fields point to.

If a field is missing or unreadable, the flow run fails with `INVALID_FIELD`, an error alert goes to Slack and AppFlow suspends the flow after a few failed runs.

The Jenkins pipeline checks every fixed field list against the target environment right after `terraform plan` (`infra/scripts/validate_appflow_field_mappings.py`) and stops the build before apply if a field is missing.
