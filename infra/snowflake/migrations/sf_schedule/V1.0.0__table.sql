USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.SCHEDULE (
    -- Standard Salesforce fields
    id                      VARCHAR(18)     NOT NULL,
    owner_id                VARCHAR(18),
    is_deleted              BOOLEAN,
    name                    VARCHAR,
    currency_iso_code       VARCHAR(3),
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
    location__c             VARCHAR(18),
    location_address__c     VARCHAR,
    total_insured_value__c  NUMBER(18, 4),
    issued_policy__c        VARCHAR(18),
    quote__c                VARCHAR(18),
    main_location__c        BOOLEAN,
    fips_code__c            VARCHAR,
    iso_3166_country__c     VARCHAR,
    cresta_code__c          VARCHAR,
    location_zip_code__c    VARCHAR,

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.SCHEDULE_STAGING LIKE SALESFORCE.SCHEDULE;
