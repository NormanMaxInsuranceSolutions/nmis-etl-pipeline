USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE SCHEMA IF NOT EXISTS SALESFORCE;

CREATE OR REPLACE TABLE SALESFORCE.CALCULATION_LOCATION (
    -- Standard Salesforce fields
    id                              VARCHAR(18)     NOT NULL,
    owner_id                        VARCHAR(18),
    is_deleted                      BOOLEAN,
    name                            VARCHAR,
    record_type_id                  VARCHAR(18),
    created_date                    TIMESTAMP_TZ,
    created_by_id                   VARCHAR(18),
    last_modified_date              TIMESTAMP_TZ,
    last_modified_by_id             VARCHAR(18),
    system_modstamp                 TIMESTAMP_TZ,
    last_viewed_date                DATE,
    last_referenced_date            DATE,

    -- Custom fields
    country__c                      VARCHAR,
    county__c                       VARCHAR,
    effective_date__c               DATE,
    expiration_date__c              DATE,
    install_date__c                 DATE,
    instrument_height_feet_agl__c   NUMBER(18, 4),
    location_latitude__s            NUMBER(18, 10),
    location_longitude__s           NUMBER(18, 10),
    nearest_address__c              VARCHAR,
    site_elevation_feet_asl__c      NUMBER(18, 4),
    site_id__c                      VARCHAR,
    state__c                        VARCHAR,
    type__c                         VARCHAR,
    status__c                       VARCHAR,
    custom_polygon_points__c        VARCHAR,
    record_type_name__c             VARCHAR,
    fips_code__c                    VARCHAR,

    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE SALESFORCE.CALCULATION_LOCATION_STAGING LIKE SALESFORCE.CALCULATION_LOCATION;