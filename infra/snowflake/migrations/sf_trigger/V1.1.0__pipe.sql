USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.TRIGGER_DATA_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Trigger__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.TRIGGER_DATA_STAGING (
      id, is_deleted, name, currency_iso_code, record_type_id,
      created_date, created_by_id, last_modified_date, last_modified_by_id,
      system_modstamp, last_viewed_date, last_referenced_date,
      structure__c, calculation_location__c, payout_table__c, radius__c,
      unit_of_measurement__c, lat__c, location_description__c, long__c,
      payout_description__c, state_province__c, trigger_type__c,
      calculation_location_type__c, payout_table_id__c, record_type_name__c,
      is_anemometer_trigger__c, fips_code__c, sub_limit__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"CurrencyIsoCode"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"CreatedDate"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          $1:"CreatedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"LastModifiedDate"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          $1:"LastModifiedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"SystemModstamp"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          $1:"Structure__c"::VARCHAR,
          $1:"Calculation_Location__c"::VARCHAR,
          $1:"Payout_Table__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Radius__c"::VARCHAR, 18, 4),
          $1:"Unit_of_Measurement__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Lat__c"::VARCHAR, 18, 7),
          $1:"Location_Description__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Long__c"::VARCHAR, 18, 7),
          $1:"Payout_Description__c"::VARCHAR,
          $1:"State_Province__c"::VARCHAR,
          $1:"Trigger_Type__c"::VARCHAR,
          $1:"Calculation_Location_Type__c"::VARCHAR,
          $1:"Payout_Table_Id__c"::VARCHAR,
          $1:"Record_Type_Name__c"::VARCHAR,
          $1:"IsAnemometerTrigger__c"::BOOLEAN,
          $1:"FIPS_Code__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Sub_Limit__c"::VARCHAR, 18, 4)
      FROM @SALESFORCE.SALESFORCE_RAW/trigger/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);
