USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.CALCULATION_LOCATION_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.CALCULATION_LOCATION_STAGING_STREAM
    ON TABLE SALESFORCE.CALCULATION_LOCATION_STAGING;

CREATE OR REPLACE TASK SALESFORCE.CALCULATION_LOCATION_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.CALCULATION_LOCATION_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.CALCULATION_LOCATION AS target
    USING (
        SELECT * FROM SALESFORCE.CALCULATION_LOCATION_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        owner_id                        = source.owner_id,
        is_deleted                      = source.is_deleted,
        name                            = source.name,
        record_type_id                  = source.record_type_id,
        last_modified_date              = source.last_modified_date,
        last_modified_by_id             = source.last_modified_by_id,
        system_modstamp                 = source.system_modstamp,
        last_viewed_date                = source.last_viewed_date,
        last_referenced_date            = source.last_referenced_date,
        country__c                      = source.country__c,
        county__c                       = source.county__c,
        effective_date__c               = source.effective_date__c,
        expiration_date__c              = source.expiration_date__c,
        install_date__c                 = source.install_date__c,
        instrument_height_feet_agl__c   = source.instrument_height_feet_agl__c,
        location_latitude__s            = source.location_latitude__s,
        location_longitude__s           = source.location_longitude__s,
        nearest_address__c              = source.nearest_address__c,
        site_elevation_feet_asl__c      = source.site_elevation_feet_asl__c,
        site_id__c                      = source.site_id__c,
        state__c                        = source.state__c,
        type__c                         = source.type__c,
        status__c                       = source.status__c,
        custom_polygon_points__c        = source.custom_polygon_points__c,
        record_type_name__c             = source.record_type_name__c,
        fips_code__c                    = source.fips_code__c
    WHEN NOT MATCHED THEN INSERT (
        id, owner_id, is_deleted, name, record_type_id, created_date, created_by_id,
        last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
        last_referenced_date, country__c, county__c, effective_date__c, expiration_date__c,
        install_date__c, instrument_height_feet_agl__c, location_latitude__s,
        location_longitude__s, nearest_address__c, site_elevation_feet_asl__c, site_id__c,
        state__c, type__c, status__c, custom_polygon_points__c, record_type_name__c, fips_code__c
    ) VALUES (
        source.id, source.owner_id, source.is_deleted, source.name, source.record_type_id,
        source.created_date, source.created_by_id, source.last_modified_date,
        source.last_modified_by_id, source.system_modstamp, source.last_viewed_date,
        source.last_referenced_date, source.country__c, source.county__c,
        source.effective_date__c, source.expiration_date__c, source.install_date__c,
        source.instrument_height_feet_agl__c, source.location_latitude__s,
        source.location_longitude__s, source.nearest_address__c,
        source.site_elevation_feet_asl__c, source.site_id__c, source.state__c,
        source.type__c, source.status__c, source.custom_polygon_points__c,
        source.record_type_name__c, source.fips_code__c
    );

ALTER TASK SALESFORCE.CALCULATION_LOCATION_MERGE_TASK RESUME;