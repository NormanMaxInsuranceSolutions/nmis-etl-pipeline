USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.PAYOUT_TABLE_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.PAYOUT_TABLE_STAGING_STREAM
    ON TABLE SALESFORCE.PAYOUT_TABLE_STAGING;

CREATE OR REPLACE TASK SALESFORCE.PAYOUT_TABLE_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.PAYOUT_TABLE_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.PAYOUT_TABLE AS target
    USING (
        SELECT * FROM SALESFORCE.PAYOUT_TABLE_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        owner_id                                    = source.owner_id,
        is_deleted                                  = source.is_deleted,
        name                                        = source.name,
        currency_iso_code                           = source.currency_iso_code,
        record_type_id                              = source.record_type_id,
        last_modified_date                          = source.last_modified_date,
        last_modified_by_id                         = source.last_modified_by_id,
        system_modstamp                             = source.system_modstamp,
        last_viewed_date                            = source.last_viewed_date,
        last_referenced_date                        = source.last_referenced_date,
        description__c                              = source.description__c,
        max_payout__c                               = source.max_payout__c,
        minimum_payout_threshold_magnitude__c       = source.minimum_payout_threshold_magnitude__c,
        minimum_payout_threshold_pga_sa03__c        = source.minimum_payout_threshold_pga_sa03__c,
        minimum_payout_threshold_ws_ciac__c         = source.minimum_payout_threshold_ws_ciac__c,
        minimum_payout__c                           = source.minimum_payout__c,
        number_of_steps__c                          = source.number_of_steps__c,
        payout_exhaustion_threshold_magnitude__c    = source.payout_exhaustion_threshold_magnitude__c,
        payout_exhaustion_threshold_pga_sa03__c     = source.payout_exhaustion_threshold_pga_sa03__c,
        payout_exhaustion_threshold_ws_ciac__c      = source.payout_exhaustion_threshold_ws_ciac__c,
        payout_name_formula__c                      = source.payout_name_formula__c,
        short_description__c                        = source.short_description__c,
        unit_of_measurement__c                      = source.unit_of_measurement__c,
        quote_payout_id__c                          = source.quote_payout_id__c
    WHEN NOT MATCHED THEN INSERT (
        id, owner_id, is_deleted, name, currency_iso_code, record_type_id,
        created_date, created_by_id, last_modified_date, last_modified_by_id,
        system_modstamp, last_viewed_date, last_referenced_date, description__c,
        max_payout__c, minimum_payout_threshold_magnitude__c,
        minimum_payout_threshold_pga_sa03__c, minimum_payout_threshold_ws_ciac__c,
        minimum_payout__c, number_of_steps__c, payout_exhaustion_threshold_magnitude__c,
        payout_exhaustion_threshold_pga_sa03__c, payout_exhaustion_threshold_ws_ciac__c,
        payout_name_formula__c, short_description__c, unit_of_measurement__c,
        quote_payout_id__c
    ) VALUES (
        source.id, source.owner_id, source.is_deleted, source.name, source.currency_iso_code,
        source.record_type_id, source.created_date, source.created_by_id,
        source.last_modified_date, source.last_modified_by_id, source.system_modstamp,
        source.last_viewed_date, source.last_referenced_date, source.description__c,
        source.max_payout__c, source.minimum_payout_threshold_magnitude__c,
        source.minimum_payout_threshold_pga_sa03__c, source.minimum_payout_threshold_ws_ciac__c,
        source.minimum_payout__c, source.number_of_steps__c,
        source.payout_exhaustion_threshold_magnitude__c,
        source.payout_exhaustion_threshold_pga_sa03__c,
        source.payout_exhaustion_threshold_ws_ciac__c, source.payout_name_formula__c,
        source.short_description__c, source.unit_of_measurement__c, source.quote_payout_id__c
    );

ALTER TASK SALESFORCE.PAYOUT_TABLE_MERGE_TASK RESUME;