-- Prerequisites: V1.2.0 applied.
-- After schemachange deploy, run:
--   snow sql -q "SHOW PIPES LIKE 'policy__c_pipe'"
-- Copy notification_channel ARN into the snowpipe_sqs_arn SSM parameter, then terraform apply.
-- Pass values via --vars: database

USE DATABASE {{ database }};

CREATE PIPE IF NOT EXISTS SALESFORCE.POLICY_PIPE
  AUTO_INGEST = TRUE
  COMMENT     = 'Auto-ingest Policy__c Parquet files from S3 data lake'
AS
COPY INTO SALESFORCE.POLICY_STAGING
FROM   @SALESFORCE.SALESFORCE_RAW/policy/
FILE_FORMAT          = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;