USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

ALTER TABLE SALESFORCE.TRANSACTION_STAGING SET DATA_RETENTION_TIME_IN_DAYS = 90;

CREATE OR REPLACE STREAM SALESFORCE.TRANSACTION_STAGING_STREAM
    ON TABLE SALESFORCE.TRANSACTION_STAGING;

CREATE OR REPLACE TASK SALESFORCE.TRANSACTION_MERGE_TASK
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE  = '5 MINUTES'
    SUSPEND_TASK_AFTER_NUM_FAILURES = 0
    WHEN SYSTEM$STREAM_HAS_DATA('SALESFORCE.TRANSACTION_STAGING_STREAM')
AS
    MERGE INTO SALESFORCE.TRANSACTION AS target
    USING (
        SELECT * FROM SALESFORCE.TRANSACTION_STAGING
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
        policy__c                       = source.policy__c,
        description__c                  = source.description__c,
        effective_date__c               = source.effective_date__c,
        gross_premium__c                = source.gross_premium__c,
        rating_factor__c                = source.rating_factor__c,
        terrorism_premium__c            = source.terrorism_premium__c,
        expiry_date_of_transaction__c   = source.expiry_date_of_transaction__c,
        transaction_premium__c          = source.transaction_premium__c,
        transaction_type__c             = source.transaction_type__c,
        generate_endorsement_file__c    = source.generate_endorsement_file__c,
        ofn_label__c                    = source.ofn_label__c,
        issued_policy__c                = source.issued_policy__c,
        transaction_type_conga__c       = source.transaction_type_conga__c,
        test_exp_date__c                = source.test_exp_date__c,
        expiry_date_of_transactions__c  = source.expiry_date_of_transactions__c,
        sum_insured_amount__c           = source.sum_insured_amount__c,
        calculation_agent_cost__c       = source.calculation_agent_cost__c,
        weatherflow_maintenance_cost__c = source.weatherflow_maintenance_cost__c,
        record_type_name__c             = source.record_type_name__c
    WHEN NOT MATCHED THEN INSERT (
        id, is_deleted, name, currency_iso_code, record_type_id,
        created_date, created_by_id, last_modified_date, last_modified_by_id,
        system_modstamp, policy__c, description__c, effective_date__c,
        gross_premium__c, rating_factor__c, terrorism_premium__c,
        expiry_date_of_transaction__c, transaction_premium__c, transaction_type__c,
        generate_endorsement_file__c, ofn_label__c, issued_policy__c,
        transaction_type_conga__c, test_exp_date__c, expiry_date_of_transactions__c,
        sum_insured_amount__c, calculation_agent_cost__c, weatherflow_maintenance_cost__c,
        record_type_name__c
    ) VALUES (
        source.id, source.is_deleted, source.name, source.currency_iso_code,
        source.record_type_id, source.created_date, source.created_by_id,
        source.last_modified_date, source.last_modified_by_id, source.system_modstamp,
        source.policy__c, source.description__c, source.effective_date__c,
        source.gross_premium__c, source.rating_factor__c, source.terrorism_premium__c,
        source.expiry_date_of_transaction__c, source.transaction_premium__c,
        source.transaction_type__c, source.generate_endorsement_file__c,
        source.ofn_label__c, source.issued_policy__c, source.transaction_type_conga__c,
        source.test_exp_date__c, source.expiry_date_of_transactions__c,
        source.sum_insured_amount__c, source.calculation_agent_cost__c,
        source.weatherflow_maintenance_cost__c, source.record_type_name__c
    );

ALTER TASK SALESFORCE.TRANSACTION_MERGE_TASK RESUME;
