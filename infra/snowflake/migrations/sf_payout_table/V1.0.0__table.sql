USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.PAYOUT_TABLE (
    -- Standard Salesforce fields
    id                                          VARCHAR(18)     NOT NULL,
    owner_id                                    VARCHAR(18),
    is_deleted                                  BOOLEAN,
    name                                        VARCHAR,
    currency_iso_code                           VARCHAR(3),
    record_type_id                              VARCHAR(18),
    created_date                                TIMESTAMP_TZ,
    created_by_id                               VARCHAR(18),
    last_modified_date                          TIMESTAMP_TZ,
    last_modified_by_id                         VARCHAR(18),
    system_modstamp                             TIMESTAMP_TZ,
    last_viewed_date                            DATE,
    last_referenced_date                        DATE,

    -- Custom fields
    description__c                              VARCHAR,
    max_payout__c                               NUMBER(18, 4),
    minimum_payout_threshold_magnitude__c       NUMBER(18, 4),
    minimum_payout_threshold_pga_sa03__c        NUMBER(18, 4),
    minimum_payout_threshold_ws_ciac__c         NUMBER(18, 4),
    minimum_payout__c                           NUMBER(18, 4),
    number_of_steps__c                          NUMBER(18, 0),
    payout_exhaustion_threshold_magnitude__c    NUMBER(18, 4),
    payout_exhaustion_threshold_pga_sa03__c     NUMBER(18, 4),
    payout_exhaustion_threshold_ws_ciac__c      NUMBER(18, 4),
    payout_name_formula__c                      VARCHAR,
    short_description__c                        VARCHAR,
    unit_of_measurement__c                      VARCHAR,
    quote_payout_id__c                          VARCHAR,

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.PAYOUT_TABLE_STAGING LIKE SALESFORCE.PAYOUT_TABLE;
