USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.TRANSACTION (
    -- Standard Salesforce fields
    id                              VARCHAR(18)     NOT NULL,
    is_deleted                      BOOLEAN,
    name                            VARCHAR,
    currency_iso_code               VARCHAR(3),
    record_type_id                  VARCHAR(18),
    created_date                    TIMESTAMP_TZ,
    created_by_id                   VARCHAR(18),
    last_modified_date              TIMESTAMP_TZ,
    last_modified_by_id             VARCHAR(18),
    system_modstamp                 TIMESTAMP_TZ,

    -- Custom fields
    policy__c                       VARCHAR(18),
    description__c                  VARCHAR,
    effective_date__c               DATE,
    gross_premium__c                NUMBER(18, 4),
    rating_factor__c                NUMBER(18, 4),
    terrorism_premium__c            NUMBER(18, 4),
    expiry_date_of_transaction__c   DATE,
    transaction_premium__c          NUMBER(18, 4),
    transaction_type__c             VARCHAR,
    generate_endorsement_file__c    VARCHAR,
    ofn_label__c                    VARCHAR,
    issued_policy__c                VARCHAR(18),
    transaction_type_conga__c       VARCHAR,
    test_exp_date__c                DATE,
    expiry_date_of_transactions__c  DATE,
    sum_insured_amount__c           NUMBER(18, 4),
    calculation_agent_cost__c       NUMBER(18, 4),
    weatherflow_maintenance_cost__c NUMBER(18, 4),
    record_type_name__c             VARCHAR,

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.TRANSACTION_STAGING LIKE SALESFORCE.TRANSACTION;
