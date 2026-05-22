USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.COVERAGE (
    -- Standard Salesforce fields
    id                      VARCHAR(18)     NOT NULL,
    owner_id                VARCHAR(18),
    is_deleted              BOOLEAN,
    name                    VARCHAR,
    record_type_id          VARCHAR(18),
    created_date            TIMESTAMP_TZ,
    created_by_id           VARCHAR(18),
    last_modified_date      TIMESTAMP_TZ,
    last_modified_by_id     VARCHAR(18),
    system_modstamp         TIMESTAMP_TZ,
    last_viewed_date        DATE,
    last_referenced_date    DATE,

    -- Custom fields
    policy__c               VARCHAR(18),
    current_structure__c    VARCHAR(18),
    product__c              VARCHAR(18),
    gross_premium__c        NUMBER(18, 4),
    limit__c                NUMBER(18, 4),
    source__c               VARCHAR,
    issued_policy__c        VARCHAR(18),
    quote__c                VARCHAR(18),
    gross_premium_om__c     NUMBER(18, 4),
    limit_om__c             NUMBER(18, 4),
    benchmark_gwp__c        NUMBER(18, 4),
    adequency__c            NUMBER(18, 4),
    benchmark_gwp_a__c      NUMBER(18, 4),
    benchmark_gwp_b__c      NUMBER(18, 4),
    benchmark_gwp_c__c      NUMBER(18, 4),

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.COVERAGE_STAGING LIKE SALESFORCE.COVERAGE;