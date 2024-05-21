{{ config(
    enabled = var('pqi_enabled', var('claims_enabled', var('tuva_marts_enabled', False))) | as_bool
) }}

select 
    encounter_id
  , data_source
  , ms_drg_code
  , ms_drg_description
  , admit_source_code
  , encounter_start_date
  , encounter_end_date
  , length_of_stay
  , primary_diagnosis_code
  , patient_id
  , facility_npi
  , paid_amount
  , {{ date_part('YEAR', 'encounter_start_date') }} as year_number
from 
    {{ ref('core__encounter') }}
where 
    encounter_type = 'acute inpatient'
