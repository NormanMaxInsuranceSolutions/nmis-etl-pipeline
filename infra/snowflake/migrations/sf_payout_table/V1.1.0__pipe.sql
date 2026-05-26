USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.PAYOUT_TABLE_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Payout_Table__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.PAYOUT_TABLE_STAGING (
      id, owner_id, is_deleted, name, currency_iso_code, record_type_id,
      created_date, created_by_id, last_modified_date, last_modified_by_id,
      system_modstamp, last_viewed_date, last_referenced_date, description__c,
      max_payout__c, minimum_payout_threshold_magnitude__c,
      minimum_payout_threshold_pga_sa03__c, minimum_payout_threshold_ws_ciac__c,
      minimum_payout__c, number_of_steps__c, payout_exhaustion_threshold_magnitude__c,
      payout_exhaustion_threshold_pga_sa03__c, payout_exhaustion_threshold_ws_ciac__c,
      payout_name_formula__c, short_description__c, unit_of_measurement__c,
      quote_payout_id__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"OwnerId"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"CurrencyIsoCode"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          $1:"CreatedDate"::TIMESTAMP_TZ,
          $1:"CreatedById"::VARCHAR,
          $1:"LastModifiedDate"::TIMESTAMP_TZ,
          $1:"LastModifiedById"::VARCHAR,
          $1:"SystemModstamp"::TIMESTAMP_TZ,
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          $1:"Description__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Max_Payout__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Minimum_Payout_Threshold_Magnitude__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Minimum_Payout_Threshold_PGA_SA03__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Minimum_Payout_Threshold_WS_CIAC__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Minimum_Payout__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Number_of_Steps__c"::VARCHAR, 18, 0),
          TRY_TO_NUMBER($1:"Payout_Exhaustion_Threshold_Magnitude__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Payout_Exhaustion_Threshold_PGA_SA03__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Payout_Exhaustion_Threshold_WS_CIAC__c"::VARCHAR, 18, 4),
          $1:"Payout_Name_Formula__c"::VARCHAR,
          $1:"Short_Description__c"::VARCHAR,
          $1:"Unit_of_Measurement__c"::VARCHAR,
          $1:"Quote_Payout_ID__c"::VARCHAR
      FROM @SALESFORCE.SALESFORCE_RAW/payout_table/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);