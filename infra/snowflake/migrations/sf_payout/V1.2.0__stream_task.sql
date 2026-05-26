USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.PAYOUT_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.PAYOUT_STAGING_STREAM
    ON TABLE SALESFORCE.PAYOUT_STAGING;

CREATE OR REPLACE TASK SALESFORCE.PAYOUT_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.PAYOUT_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.PAYOUT AS target
    USING (
        SELECT * FROM SALESFORCE.PAYOUT_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        is_deleted              = source.is_deleted,
        name                    = source.name,
        currency_iso_code       = source.currency_iso_code,
        record_type_id          = source.record_type_id,
        last_modified_date      = source.last_modified_date,
        last_modified_by_id     = source.last_modified_by_id,
        system_modstamp         = source.system_modstamp,
        last_viewed_date        = source.last_viewed_date,
        last_referenced_date    = source.last_referenced_date,
        payout_table__c         = source.payout_table__c,
        hazard_magnitude__c     = source.hazard_magnitude__c,
        hazard_pga_sa03__c      = source.hazard_pga_sa03__c,
        hazard_windspeed_ciac__c = source.hazard_windspeed_ciac__c,
        payout__c               = source.payout__c,
        hazard__c               = source.hazard__c,
        hazard_pressure_mb__c   = source.hazard_pressure_mb__c,
        hazard_transformer__c   = source.hazard_transformer__c,
        hazard_ach__c           = source.hazard_ach__c,
        hazard_precipitation__c = source.hazard_precipitation__c,
        hazard_water_level__c   = source.hazard_water_level__c,
        hazard_wave_height__c   = source.hazard_wave_height__c
    WHEN NOT MATCHED THEN INSERT (
        id, is_deleted, name, currency_iso_code, record_type_id, created_date, created_by_id,
        last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
        last_referenced_date, payout_table__c, hazard_magnitude__c, hazard_pga_sa03__c,
        hazard_windspeed_ciac__c, payout__c, hazard__c, hazard_pressure_mb__c,
        hazard_transformer__c, hazard_ach__c, hazard_precipitation__c,
        hazard_water_level__c, hazard_wave_height__c
    ) VALUES (
        source.id, source.is_deleted, source.name, source.currency_iso_code,
        source.record_type_id, source.created_date, source.created_by_id,
        source.last_modified_date, source.last_modified_by_id, source.system_modstamp,
        source.last_viewed_date, source.last_referenced_date, source.payout_table__c,
        source.hazard_magnitude__c, source.hazard_pga_sa03__c, source.hazard_windspeed_ciac__c,
        source.payout__c, source.hazard__c, source.hazard_pressure_mb__c,
        source.hazard_transformer__c, source.hazard_ach__c, source.hazard_precipitation__c,
        source.hazard_water_level__c, source.hazard_wave_height__c
    );

ALTER TASK SALESFORCE.PAYOUT_MERGE_TASK RESUME;