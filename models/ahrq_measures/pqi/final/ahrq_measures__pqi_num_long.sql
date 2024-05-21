{{ config(
    enabled = var('pqi_enabled', var('claims_enabled', var('tuva_marts_enabled', False))) | as_bool
) }}

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 1 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_01_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 3 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_03_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 5 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_05_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 7 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_07_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 8 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_08_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 11 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_11_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 12 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_12_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 14 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_14_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 15 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_15_num') }} as n

union all

select
    n.data_source
  , n.patient_id
  , n.year_number
  , n.encounter_id
  , 16 as pqi_number
  , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('ahrq_measures__int_pqi_16_num') }} as n
