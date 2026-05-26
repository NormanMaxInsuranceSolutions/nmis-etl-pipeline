USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.SCHEDULE_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.SCHEDULE_STAGING_STREAM
    ON TABLE SALESFORCE.SCHEDULE_STAGING;

CREATE OR REPLACE TASK SALESFORCE.SCHEDULE_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.SCHEDULE_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.SCHEDULE AS target
    USING (
        SELECT * FROM SALESFORCE.SCHEDULE_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        owner_id                = source.owner_id,
        is_deleted              = source.is_deleted,
        name                    = source.name,
        currency_iso_code       = source.currency_iso_code,
        record_type_id          = source.record_type_id,
        last_modified_date      = source.last_modified_date,
        last_modified_by_id     = source.last_modified_by_id,
        system_modstamp         = source.system_modstamp,
        last_viewed_date        = source.last_viewed_date,
        last_referenced_date    = source.last_referenced_date,
        policy__c               = source.policy__c,
        location__c             = source.location__c,
        location_address__c     = source.location_address__c,
        total_insured_value__c  = source.total_insured_value__c,
        issued_policy__c        = source.issued_policy__c,
        quote__c                = source.quote__c,
        main_location__c        = source.main_location__c,
        fips_code__c            = source.fips_code__c,
        iso_3166_country__c     = source.iso_3166_country__c,
        cresta_code__c          = source.cresta_code__c,
        location_zip_code__c    = source.location_zip_code__c
    WHEN NOT MATCHED THEN INSERT (
        id, owner_id, is_deleted, name, currency_iso_code, record_type_id,
        created_date, created_by_id, last_modified_date, last_modified_by_id,
        system_modstamp, last_viewed_date, last_referenced_date,
        policy__c, location__c, location_address__c, total_insured_value__c,
        issued_policy__c, quote__c, main_location__c, fips_code__c,
        iso_3166_country__c, cresta_code__c, location_zip_code__c
    ) VALUES (
        source.id, source.owner_id, source.is_deleted, source.name,
        source.currency_iso_code, source.record_type_id, source.created_date,
        source.created_by_id, source.last_modified_date, source.last_modified_by_id,
        source.system_modstamp, source.last_viewed_date, source.last_referenced_date,
        source.policy__c, source.location__c, source.location_address__c,
        source.total_insured_value__c, source.issued_policy__c, source.quote__c,
        source.main_location__c, source.fips_code__c, source.iso_3166_country__c,
        source.cresta_code__c, source.location_zip_code__c
    );

ALTER TASK SALESFORCE.SCHEDULE_MERGE_TASK RESUME;
