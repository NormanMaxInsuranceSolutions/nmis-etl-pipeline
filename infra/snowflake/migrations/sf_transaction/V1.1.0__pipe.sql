USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.TRANSACTION_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Transaction__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.TRANSACTION_STAGING (
      id, is_deleted, name, currency_iso_code, record_type_id,
      created_date, created_by_id, last_modified_date, last_modified_by_id,
      system_modstamp, policy__c, description__c, effective_date__c,
      gross_premium__c, rating_factor__c, terrorism_premium__c,
      expiry_date_of_transaction__c, transaction_premium__c, transaction_type__c,
      generate_endorsement_file__c, ofn_label__c, issued_policy__c,
      transaction_type_conga__c, test_exp_date__c, expiry_date_of_transactions__c,
      sum_insured_amount__c, calculation_agent_cost__c, weatherflow_maintenance_cost__c,
      record_type_name__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"CurrencyIsoCode"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"CreatedDate"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          $1:"CreatedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"LastModifiedDate"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          $1:"LastModifiedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"SystemModstamp"::VARCHAR, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'),
          $1:"Policy__c"::VARCHAR,
          $1:"Description__c"::VARCHAR,
          TRY_TO_DATE($1:"Effective_Date__c"::VARCHAR),
          TRY_TO_NUMBER($1:"Gross_Premium__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Rating_Factor__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Terrorism_Premium__c"::VARCHAR, 18, 4),
          TRY_TO_DATE($1:"Expiry_Date_of_Transaction__c"::VARCHAR),
          TRY_TO_NUMBER($1:"Transaction_Premium__c"::VARCHAR, 18, 4),
          $1:"Transaction_Type__c"::VARCHAR,
          $1:"Generate_Endorsement_File__c"::VARCHAR,
          $1:"OFN_Label__c"::VARCHAR,
          $1:"Issued_Policy__c"::VARCHAR,
          $1:"Transaction_Type_Conga__c"::VARCHAR,
          TRY_TO_DATE($1:"Test_Exp_Date__c"::VARCHAR),
          TRY_TO_DATE($1:"Expiry_Date_of_Transactions__c"::VARCHAR),
          TRY_TO_NUMBER($1:"Sum_Insured_Amount__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Calculation_Agent_Cost__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Weatherflow_Maintenance_Cost__c"::VARCHAR, 18, 4),
          $1:"Record_Type_Name__c"::VARCHAR
      FROM @SALESFORCE.SALESFORCE_RAW/transaction/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);
