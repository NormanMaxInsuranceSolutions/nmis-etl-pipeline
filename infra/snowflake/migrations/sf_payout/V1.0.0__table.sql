USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.PAYOUT (
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
    payout_table__c             VARCHAR(18),
    hazard_magnitude__c         NUMBER(18, 4),
    hazard_pga_sa03__c          NUMBER(18, 4),
    hazard_windspeed_ciac__c    NUMBER(18, 4),
    payout__c                   NUMBER(18, 4),
    hazard__c                   VARCHAR,
    hazard_pressure_mb__c       NUMBER(18, 4),
    hazard_transformer__c       NUMBER(18, 4),
    hazard_ach__c               NUMBER(18, 4),
    hazard_precipitation__c     NUMBER(18, 4),
    hazard_water_level__c       NUMBER(18, 4),
    hazard_wave_height__c       NUMBER(18, 4),

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.PAYOUT_STAGING LIKE SALESFORCE.PAYOUT;