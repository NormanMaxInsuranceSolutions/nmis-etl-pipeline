USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.COVERAGE_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.COVERAGE_STAGING_STREAM
    ON TABLE SALESFORCE.COVERAGE_STAGING;

CREATE OR REPLACE TASK SALESFORCE.COVERAGE_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.COVERAGE_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.COVERAGE AS target
    USING (
        SELECT * FROM SALESFORCE.COVERAGE_STAGING
        QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY last_modified_date DESC NULLS LAST) = 1
    ) AS source
    ON target.id = source.id
    WHEN MATCHED AND source.is_deleted = TRUE THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        owner_id                = source.owner_id,
        is_deleted              = source.is_deleted,
        name                    = source.name,
        record_type_id          = source.record_type_id,
        last_modified_date      = source.last_modified_date,
        last_modified_by_id     = source.last_modified_by_id,
        system_modstamp         = source.system_modstamp,
        last_viewed_date        = source.last_viewed_date,
        last_referenced_date    = source.last_referenced_date,
        policy__c               = source.policy__c,
        current_structure__c    = source.current_structure__c,
        product__c              = source.product__c,
        gross_premium__c        = source.gross_premium__c,
        limit__c                = source.limit__c,
        source__c               = source.source__c,
        issued_policy__c        = source.issued_policy__c,
        quote__c                = source.quote__c,
        gross_premium_om__c     = source.gross_premium_om__c,
        limit_om__c             = source.limit_om__c,
        benchmark_gwp__c        = source.benchmark_gwp__c,
        adequency__c            = source.adequency__c,
        benchmark_gwp_a__c      = source.benchmark_gwp_a__c,
        benchmark_gwp_b__c      = source.benchmark_gwp_b__c,
        benchmark_gwp_c__c      = source.benchmark_gwp_c__c
    WHEN NOT MATCHED THEN INSERT (
        id, owner_id, is_deleted, name, record_type_id, created_date, created_by_id,
        last_modified_date, last_modified_by_id, system_modstamp, last_viewed_date,
        last_referenced_date, policy__c, current_structure__c, product__c,
        gross_premium__c, limit__c, source__c, issued_policy__c, quote__c,
        gross_premium_om__c, limit_om__c, benchmark_gwp__c, adequency__c,
        benchmark_gwp_a__c, benchmark_gwp_b__c, benchmark_gwp_c__c
    ) VALUES (
        source.id, source.owner_id, source.is_deleted, source.name, source.record_type_id,
        source.created_date, source.created_by_id, source.last_modified_date,
        source.last_modified_by_id, source.system_modstamp, source.last_viewed_date,
        source.last_referenced_date, source.policy__c, source.current_structure__c,
        source.product__c, source.gross_premium__c, source.limit__c, source.source__c,
        source.issued_policy__c, source.quote__c, source.gross_premium_om__c,
        source.limit_om__c, source.benchmark_gwp__c, source.adequency__c,
        source.benchmark_gwp_a__c, source.benchmark_gwp_b__c, source.benchmark_gwp_c__c
    );

ALTER TASK SALESFORCE.COVERAGE_MERGE_TASK RESUME;