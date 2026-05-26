USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.CALCULATION_LOCATION_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Calculation_Location__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.CALCULATION_LOCATION_STAGING (
      id, owner_id, is_deleted, name, record_type_id, created_date, created_by_id,
      last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
      last_referenced_date, country__c, county__c, effective_date__c, expiration_date__c,
      install_date__c, instrument_height_feet_agl__c, location_latitude__s,
      location_longitude__s, nearest_address__c, site_elevation_feet_asl__c, site_id__c,
      state__c, type__c, status__c, custom_polygon_points__c, record_type_name__c, fips_code__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"OwnerId"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          $1:"CreatedDate"::TIMESTAMP_TZ,
          $1:"CreatedById"::VARCHAR,
          $1:"LastModifiedDate"::TIMESTAMP_TZ,
          $1:"LastModifiedById"::VARCHAR,
          $1:"SystemModstamp"::TIMESTAMP_TZ,
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          $1:"Country__c"::VARCHAR,
          $1:"County__c"::VARCHAR,
          TRY_TO_DATE($1:"Effective_Date__c"::VARCHAR),
          TRY_TO_DATE($1:"Expiration_Date__c"::VARCHAR),
          TRY_TO_DATE($1:"Install_Date__c"::VARCHAR),
          TRY_TO_NUMBER($1:"Instrument_Height_feet_AGL__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Location__Latitude__s"::VARCHAR, 18, 10),
          TRY_TO_NUMBER($1:"Location__Longitude__s"::VARCHAR, 18, 10),
          $1:"Nearest_Address__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Site_Elevation_feet_ASL__c"::VARCHAR, 18, 4),
          $1:"Site_ID__c"::VARCHAR,
          $1:"State__c"::VARCHAR,
          $1:"Type__c"::VARCHAR,
          $1:"Status__c"::VARCHAR,
          $1:"Custom_Polygon_Points__c"::VARCHAR,
          $1:"Record_Type_Name__c"::VARCHAR,
          $1:"FIPS_Code__c"::VARCHAR
      FROM @SALESFORCE.SALESFORCE_RAW/calculation_location/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);