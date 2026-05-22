USE ROLE ACCOUNTADMIN;
USE DATABASE {env}_NMIS_ETL_PIPELINE;

CREATE OR REPLACE PIPE SALESFORCE.POLICY_PIPE
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingest Policy__c Parquet files from S3 data lake'
  AS
  COPY INTO SALESFORCE.POLICY_STAGING (
      id, owner_id, is_deleted, name, record_type_id, created_date, created_by_id,
      last_modified_date, last_modified_by_id, system_modstamp, last_activity_date,
      last_viewed_date, last_referenced_date, agency__c, available_recovery__c,
      brokerage_percent_of_gross_premium__c, carrier__c, cover_type_1__c, cover_type_2__c,
      cover_type_3__c, coverholder_name__c, date_first_written__c, effective_date__c,
      expiration_date__c, location_of_risk_county__c, named_insured__c,
      number_of_transactions__c, oldpolicy__c, period_of_cover_narrative__c, policy_basis__c,
      policy_number__c, policy_status__c, policy_term__c, producer__c, producing_agent__c,
      product__c, quote__c, reference_number__c, reinsurance_basis__c, renewal_of__c,
      risk_code__c, sales_lead__c, sum_insured_amount__c, sum_insured_currency__c,
      surplus_lines_broker_country__c, surplus_lines_license__c, tria_accepted__c,
      tria_premium__c, tria_sign_date__c, total_gross_written_premium__c, type_of_insurance__c,
      us_classification_of_risk__c, agreement_no__c, coverholder_pin__c,
      industrial_sector_of_the_insured__c, insured_country__c, insured_full_name__c,
      insured_state_province_territory__c, naic_code__c, peril__c, risk_expiry_date__c,
      risk_inception_date__c, surplus_lines_broker_address__c, surplus_lines_broker_name__c,
      surplus_lines_broker_state__c, surplus_lines_broker_zip_code__c,
      unique_market_reference__c, year_of_account__c, location_of_risk_country__c,
      state_of_filing__c, location_of_risk_state_province__c,
      active_underwriter_discretionary_discoun__c, complex_risk__c, declination_reason__c,
      loss_reason__c, referred_to_pricing_group__c, submission__c, brokerage_name__c,
      product_conga__c, total_indemnity_paid__c, remaining_limit__c, account_type__c,
      insurance_type__c, risk_code_formula__c, diligence_search__c,
      number_of_transactions_rollup__c, total_gross_written_premium_rollup__c,
      sharepoint_folder__c, taxes_paid_by_brooker__c, surplus_lines_license_agent__c,
      surplus_lines_license_number__c, surplus_lines_license_state__c, quote_prepared_by__c,
      unique_market_reference_om__c, record_type_name__c, premium_subtracted__c,
      has_sublimit__c, peril_picklist__c, policy_number_formula__c, policy_expired__c,
      policy_forms_generated__c, invoice_forms_generated__c, surplus_lines_agency_name__c,
      surplus_lines_broker_city__c, producer_formula__c, number_of_claims__c,
      number_of_denied_claims__c, agent_incentive_program__c, bound_via__c,
      year_of_account_om__c, entity_type__c, parent_brokerage_name__c
  )
  FROM (
      SELECT
          $1:"Id"::VARCHAR,
          $1:"OwnerId"::VARCHAR,
          $1:"IsDeleted"::BOOLEAN,
          $1:"Name"::VARCHAR,
          $1:"RecordTypeId"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"CreatedDate"::VARCHAR),
          $1:"CreatedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"LastModifiedDate"::VARCHAR),
          $1:"LastModifiedById"::VARCHAR,
          TRY_TO_TIMESTAMP_TZ($1:"SystemModstamp"::VARCHAR),
          TRY_TO_DATE($1:"LastActivityDate"::VARCHAR),
          TRY_TO_DATE($1:"LastViewedDate"::VARCHAR),
          TRY_TO_DATE($1:"LastReferencedDate"::VARCHAR),
          NULL::VARCHAR,                                                                    -- agency__c (not in AppFlow export)
          TRY_TO_NUMBER($1:"Available_Recovery__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Brokerage_Percent_of_Gross_Premium__c"::VARCHAR, 18, 4),
          NULL::VARCHAR,                                                                    -- carrier__c (not in AppFlow export)
          $1:"Cover_Type_1__c"::VARCHAR,
          $1:"Cover_Type_2__c"::VARCHAR,
          $1:"Cover_Type_3__c"::VARCHAR,
          $1:"Coverholder_Name__c"::VARCHAR,
          TRY_TO_DATE($1:"Date_First_Written__c"::VARCHAR),
          TRY_TO_DATE($1:"Effective_Date__c"::VARCHAR),
          TRY_TO_DATE($1:"Expiration_Date__c"::VARCHAR),
          $1:"Location_of_Risk_County__c"::VARCHAR,
          NULL::VARCHAR,                                                                    -- named_insured__c (not in AppFlow export)
          TRY_TO_NUMBER($1:"Number_of_Transactions__c"::VARCHAR, 18, 0),
          NULL::VARCHAR,                                                                    -- oldpolicy__c (not in AppFlow export)
          TRY_TO_NUMBER($1:"Period_of_Cover_Narrative__c"::VARCHAR, 18, 4),
          $1:"Policy_Basis__c"::VARCHAR,
          NULL::VARCHAR,                                                                    -- policy_number__c (not in AppFlow export)
          $1:"Policy_Status__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Policy_Term__c"::VARCHAR, 18, 4),
          NULL::VARCHAR,                                                                    -- producer__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- producing_agent__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- product__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- quote__c (not in AppFlow export)
          $1:"Reference_Number__c"::VARCHAR,
          $1:"Reinsurance_Basis__c"::VARCHAR,
          $1:"Renewal_Of__c"::VARCHAR,
          $1:"Risk_Code__c"::VARCHAR,
          $1:"Sales_Lead__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Sum_Insured_Amount__c"::VARCHAR, 18, 4),
          NULLIF($1:"Sum_Insured_Currency__c"::VARCHAR, 'null'),
          $1:"Surplus_Lines_Broker_Country__c"::VARCHAR,
          NULL::VARCHAR,                                                                    -- surplus_lines_license__c (not in AppFlow export)
          $1:"TRIA_Accepted__c"::BOOLEAN,
          TRY_TO_NUMBER($1:"TRIA_Premium__c"::VARCHAR, 18, 4),
          TRY_TO_DATE($1:"TRIA_Sign_Date__c"::VARCHAR),
          TRY_TO_NUMBER($1:"Total_Gross_Written_Premium__c"::VARCHAR, 18, 4),
          $1:"Type_of_Insurance__c"::VARCHAR,
          $1:"US_Classification_of_Risk__c"::VARCHAR,
          $1:"Agreement_No__c"::VARCHAR,
          $1:"Coverholder_PIN__c"::VARCHAR,
          $1:"Industrial_Sector_of_the_Insured__c"::VARCHAR,
          $1:"Insured_Country__c"::VARCHAR,
          $1:"Insured_Full_Name__c"::VARCHAR,
          $1:"Insured_State_Province_Territory__c"::VARCHAR,
          $1:"NAIC_Code__c"::VARCHAR,
          $1:"Peril__c"::VARCHAR,
          TRY_TO_DATE($1:"Risk_Expiry_Date__c"::VARCHAR),
          TRY_TO_DATE($1:"Risk_Inception_Date__c"::VARCHAR),
          $1:"Surplus_Lines_Broker_Address__c"::VARCHAR,
          $1:"Surplus_Lines_Broker_Name__c"::VARCHAR,
          $1:"Surplus_Lines_Broker_State__c"::VARCHAR,
          $1:"Surplus_Lines_Broker_Zip_Code__c"::VARCHAR,
          $1:"Unique_Market_Reference__c"::VARCHAR,
          NULLIF($1:"Year_of_Account__c"::VARCHAR, 'null'),
          $1:"Location_of_Risk_Country__c"::VARCHAR,
          $1:"State_of_Filing__c"::VARCHAR,
          $1:"Location_of_Risk_State_Province__c"::VARCHAR,
          $1:"Active_Underwriter_Discretionary_Discoun__c"::BOOLEAN,
          $1:"Complex_Risk__c"::BOOLEAN,
          $1:"Declination_Reason__c"::VARCHAR,
          $1:"Loss_Reason__c"::VARCHAR,
          $1:"Referred_to_Pricing_Group__c"::BOOLEAN,
          NULL::VARCHAR,                                                                    -- submission__c (not in AppFlow export)
          $1:"Brokerage_Name__c"::VARCHAR,
          $1:"Product_Conga__c"::VARCHAR,
          TRY_TO_NUMBER($1:"Total_Indemnity_Paid__c"::VARCHAR, 18, 4),
          TRY_TO_NUMBER($1:"Remaining_Limit__c"::VARCHAR, 18, 4),
          $1:"Account_Type__c"::VARCHAR,
          $1:"Insurance_Type__c"::VARCHAR,
          $1:"Risk_Code_Formula__c"::VARCHAR,
          $1:"Diligence_Search__c"::BOOLEAN,
          TRY_TO_NUMBER($1:"Number_of_Transactions_Rollup__c"::VARCHAR, 18, 0),
          TRY_TO_NUMBER($1:"Total_Gross_Written_Premium_Rollup__c"::VARCHAR, 18, 4),
          $1:"Sharepoint_Folder__c"::VARCHAR,
          $1:"Taxes_Paid_by_Brooker__c"::BOOLEAN,
          $1:"Surplus_Lines_License_Agent__c"::VARCHAR,
          $1:"Surplus_Lines_License_Number__c"::VARCHAR,
          $1:"Surplus_Lines_License_State__c"::VARCHAR,
          NULL::VARCHAR,                                                                    -- quote_prepared_by__c (not in AppFlow export)
          $1:"Unique_Market_Reference_OM__c"::VARCHAR,
          $1:"Record_Type_Name__c"::VARCHAR,
          $1:"Premium_Subtracted__c"::BOOLEAN,
          $1:"Has_Sublimit__c"::BOOLEAN,
          $1:"Peril_Picklist__c"::VARCHAR,
          $1:"Policy_Number_Formula__c"::VARCHAR,
          $1:"Policy_Expired__c"::BOOLEAN,
          $1:"Policy_Forms_Generated__c"::BOOLEAN,
          $1:"Invoice_Forms_Generated__c"::BOOLEAN,
          NULL::VARCHAR,                                                                    -- surplus_lines_agency_name__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- surplus_lines_broker_city__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- producer_formula__c (not in AppFlow export)
          NULL::NUMBER(18, 0),                                                             -- number_of_claims__c (not in AppFlow export)
          NULL::NUMBER(18, 0),                                                             -- number_of_denied_claims__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- agent_incentive_program__c (not in AppFlow export)
          NULL::VARCHAR,                                                                    -- bound_via__c (not in AppFlow export)
          NULLIF($1:"Year_Of_Account_OM__c"::VARCHAR, 'null'),
          NULL::VARCHAR,                                                                    -- entity_type__c (not in AppFlow export)
          NULL::VARCHAR                                                                     -- parent_brokerage_name__c (not in AppFlow export)
      FROM @SALESFORCE.SALESFORCE_RAW/policy/
  )
  FILE_FORMAT = (FORMAT_NAME = SALESFORCE.PARQUET_FORMAT);