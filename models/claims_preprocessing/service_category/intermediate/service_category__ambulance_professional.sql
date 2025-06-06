{{ config(
     enabled = var('claims_preprocessing_enabled', var('claims_enabled', var('tuva_marts_enabled', False))) | as_bool
   )
}}

select distinct
    claim_id
  , claim_line_number
  , data_source
  , claim_line_id
  , 'ancillary' as service_category_1
  , 'ambulance' as service_category_2
  , 'ambulance' as service_category_3
  , '{{ this.name }}' as source_model_name
  , '{{ var('tuva_last_run') }}' as tuva_last_run
from {{ ref('service_category__stg_medical_claim') }}
where
  claim_type = 'professional'
  and (
    hcpcs_code between 'A0425' and 'A0436'
    or place_of_service_code in ('41', '42')
  )
