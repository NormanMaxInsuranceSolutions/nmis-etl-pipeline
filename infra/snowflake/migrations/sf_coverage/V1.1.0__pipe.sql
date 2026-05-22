USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.COVERAGE_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Coverage__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.COVERAGE_STAGING (
      id, owner_id, is_deleted, name, record_type_id, created_date, created_by_id,
      last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
      last_referenced_date, policy__c, current_structure__c, product__c,
      gross_premium__c, limit__c, source__c, issued_policy__c, quote__c,
      gross_premium_om__c, limit_om__c, benchmark_gwp__c, adequency__c,
      benchmark_gwp_a__c, benchmark_gwp_b__c, benchmark_gwp_c__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"OwnerId"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"CreatedDate"::VARCHAR),
          $1:"CreatedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"LastModifiedDate"::VARCHAR),
          $1:"LastModifiedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"SystemModstamp"::VARCHAR),
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          $1:"Policy__c"::VARCHAR,
          $1:"Current_Structure__c"::VARCHAR,
          $1:"Product__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Gross_Premium__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Limit__c"::VARCHAR, 18, 4),
          $1:"Source__c"::VARCHAR,
          $1:"Issued_Policy__c"::VARCHAR,
          $1:"Quote__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Gross_Premium_OM__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Limit_OM__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Benchmark_GWP__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Adequency__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Benchmark_GWP_A__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Benchmark_GWP_B__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Benchmark_GWP_C__c"::VARCHAR, 18, 4)
      FROM @SALESFORCE.SALESFORCE_RAW/coverage/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);