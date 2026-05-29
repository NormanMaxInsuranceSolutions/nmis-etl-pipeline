USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.SCHEDULE_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Schedule__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.SCHEDULE_STAGING (
      id, owner_id, is_deleted, name, currency_iso_code, record_type_id,
      created_date, created_by_id, last_modified_date, last_modified_by_id,
      system_modstamp, last_viewed_date, last_referenced_date,
      policy__c, location__c, location_address__c, total_insured_value__c,
      issued_policy__c, quote__c, main_location__c, fips_code__c,
      iso_3166_country__c, cresta_code__c, location_zip_code__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"OwnerId"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"CurrencyIsoCode"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ(REGEXP_REPLACE($1:"CreatedDate"::VARCHAR, '([+-][0-9]{2})([0-9]{2})$', '\\1:\\2')),
          $1:"CreatedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ(REGEXP_REPLACE($1:"LastModifiedDate"::VARCHAR, '([+-][0-9]{2})([0-9]{2})$', '\\1:\\2')),
          $1:"LastModifiedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ(REGEXP_REPLACE($1:"SystemModstamp"::VARCHAR, '([+-][0-9]{2})([0-9]{2})$', '\\1:\\2')),
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          $1:"Policy__c"::VARCHAR,
          $1:"Location__c"::VARCHAR,
          $1:"Location_Address__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Total_Insured_Value__c"::VARCHAR, 18, 4),
          $1:"Issued_Policy__c"::VARCHAR,
          $1:"Quote__c"::VARCHAR,
          $1:"Main_Location__c"::BOOLEAN,
          $1:"FIPS_Code__c"::VARCHAR,
          $1:"ISO_3166_Country__c"::VARCHAR,
          $1:"Cresta_Code__c"::VARCHAR,
          $1:"Location_Zip_Code__c"::VARCHAR
      FROM @SALESFORCE.SALESFORCE_RAW/schedule/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);
