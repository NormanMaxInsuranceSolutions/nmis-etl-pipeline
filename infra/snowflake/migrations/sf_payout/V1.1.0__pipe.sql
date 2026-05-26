USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.PAYOUT_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Payout__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.PAYOUT_STAGING (
      id, is_deleted, name, currency_iso_code, record_type_id, created_date, created_by_id,
      last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
      last_referenced_date, payout_table__c, hazard_magnitude__c, hazard_pga_sa03__c,
      hazard_windspeed_ciac__c, payout__c, hazard__c, hazard_pressure_mb__c,
      hazard_transformer__c, hazard_ach__c, hazard_precipitation__c,
      hazard_water_level__c, hazard_wave_height__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
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
          $1:"Payout_Table__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Hazard_Magnitude__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_PGA_SA03__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_Windspeed_CIAC__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Payout__c"::VARCHAR, 18, 4),
          $1:"Hazard__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Hazard_Pressure_mb__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_Transformer__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_ACH__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_Precipitation__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_Water_Level__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Hazard_Wave_Height__c"::VARCHAR, 18, 4)
      FROM @SALESFORCE.SALESFORCE_RAW/payout/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);