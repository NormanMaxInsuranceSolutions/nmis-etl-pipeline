-- Prerequisites: V1.1.0 applied, SSM params updated, terraform apply run.
-- Pass values via --vars: bucket, database

USE DATABASE {{ database }};

CREATE FILE FORMAT IF NOT EXISTS SALESFORCE.PARQUET_FORMAT
  TYPE               = PARQUET
  SNAPPY_COMPRESSION = TRUE;

CREATE STAGE IF NOT EXISTS SALESFORCE.SALESFORCE_RAW
  STORAGE_INTEGRATION = {{ integration }}
  URL                 = 's3://{{ bucket }}/raw/'
  FILE_FORMAT         = SALESFORCE.PARQUET_FORMAT;