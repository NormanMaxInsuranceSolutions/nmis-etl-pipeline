USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.TRIGGER_DATA (
    -- Standard Salesforce fields
    id                          VARCHAR(18)     NOT NULL,
    is_deleted                  BOOLEAN,
    name                        VARCHAR,
    currency_iso_code           VARCHAR(3),
    record_type_id              VARCHAR(18),
    created_date                TIMESTAMP_TZ,
    created_by_id               VARCHAR(18),
    last_modified_date          TIMESTAMP_TZ,
    last_modified_by_id         VARCHAR(18),
    system_modstamp             TIMESTAMP_TZ,
    last_viewed_date            DATE,
    last_referenced_date        DATE,

    -- Custom fields
    structure__c                VARCHAR(18),
    calculation_location__c     VARCHAR(18),
    payout_table__c             VARCHAR(18),
    radius__c                   NUMBER(18, 4),
    unit_of_measurement__c      VARCHAR,
    lat__c                      NUMBER(18, 7),
    location_description__c     VARCHAR,
    long__c                     NUMBER(18, 7),
    payout_description__c       VARCHAR,
    state_province__c           VARCHAR,
    trigger_type__c             VARCHAR,
    calculation_location_type__c VARCHAR,
    payout_table_id__c          VARCHAR,
    record_type_name__c         VARCHAR,
    is_anemometer_trigger__c    BOOLEAN,
    fips_code__c                VARCHAR,
    sub_limit__c                NUMBER(18, 4),

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.TRIGGER_DATA_STAGING LIKE SALESFORCE.TRIGGER_DATA;
