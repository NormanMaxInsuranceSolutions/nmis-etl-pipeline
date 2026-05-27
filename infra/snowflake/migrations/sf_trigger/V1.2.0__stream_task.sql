USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.TRIGGER_DATA_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.TRIGGER_DATA_STAGING_STREAM
    ON TABLE SALESFORCE.TRIGGER_DATA_STAGING;

CREATE OR REPLACE TASK SALESFORCE.TRIGGER_DATA_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.TRIGGER_DATA_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.TRIGGER_DATA AS target
    USING (
        SELECT * FROM SALESFORCE.TRIGGER_DATA_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        is_deleted                      = source.is_deleted,
        name                            = source.name,
        currency_iso_code               = source.currency_iso_code,
        record_type_id                  = source.record_type_id,
        last_modified_date              = source.last_modified_date,
        last_modified_by_id             = source.last_modified_by_id,
        system_modstamp                 = source.system_modstamp,
        last_viewed_date                = source.last_viewed_date,
        last_referenced_date            = source.last_referenced_date,
        structure__c                    = source.structure__c,
        calculation_location__c         = source.calculation_location__c,
        payout_table__c                 = source.payout_table__c,
        radius__c                       = source.radius__c,
        unit_of_measurement__c          = source.unit_of_measurement__c,
        lat__c                          = source.lat__c,
        location_description__c         = source.location_description__c,
        long__c                         = source.long__c,
        payout_description__c           = source.payout_description__c,
        state_province__c               = source.state_province__c,
        trigger_type__c                 = source.trigger_type__c,
        calculation_location_type__c    = source.calculation_location_type__c,
        payout_table_id__c              = source.payout_table_id__c,
        record_type_name__c             = source.record_type_name__c,
        is_anemometer_trigger__c        = source.is_anemometer_trigger__c,
        fips_code__c                    = source.fips_code__c,
        sub_limit__c                    = source.sub_limit__c
    WHEN NOT MATCHED THEN INSERT (
        id, is_deleted, name, currency_iso_code, record_type_id,
        created_date, created_by_id, last_modified_date, last_modified_by_id,
        system_modstamp, last_viewed_date, last_referenced_date,
        structure__c, calculation_location__c, payout_table__c, radius__c,
        unit_of_measurement__c, lat__c, location_description__c, long__c,
        payout_description__c, state_province__c, trigger_type__c,
        calculation_location_type__c, payout_table_id__c, record_type_name__c,
        is_anemometer_trigger__c, fips_code__c, sub_limit__c
    ) VALUES (
        source.id, source.is_deleted, source.name, source.currency_iso_code,
        source.record_type_id, source.created_date, source.created_by_id,
        source.last_modified_date, source.last_modified_by_id, source.system_modstamp,
        source.last_viewed_date, source.last_referenced_date,
        source.structure__c, source.calculation_location__c, source.payout_table__c,
        source.radius__c, source.unit_of_measurement__c, source.lat__c,
        source.location_description__c, source.long__c, source.payout_description__c,
        source.state_province__c, source.trigger_type__c,
        source.calculation_location_type__c, source.payout_table_id__c,
        source.record_type_name__c, source.is_anemometer_trigger__c,
        source.fips_code__c, source.sub_limit__c
    );

ALTER TASK SALESFORCE.TRIGGER_DATA_MERGE_TASK RESUME;
