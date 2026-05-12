-- Prerequisites: terraform apply must be run first.
-- Pass values via --vars: role_arn, bucket
-- After schemachange deploy, run:
--   snow sql -q "DESC INTEGRATION s3_nmis_etl_data_lake"
-- Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID into SSM, then terraform apply.

CREATE STORAGE INTEGRATION IF NOT EXISTS {{ integration }}
  TYPE                      = EXTERNAL_STAGE
  STORAGE_PROVIDER          = 'S3'
  ENABLED                   = TRUE
  STORAGE_AWS_ROLE_ARN      = '{{ role_arn }}'
  STORAGE_ALLOWED_LOCATIONS = ('s3://{{ bucket }}/raw/');