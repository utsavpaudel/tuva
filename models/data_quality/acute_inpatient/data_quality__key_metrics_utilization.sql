{{ config(
    enabled = var('claims_enabled', False)
) }}

with member_months as (

    select
        count(1) as member_months
    from {{ ref('financial_pmpm__pmpm_prep') }}

)

, visits as (

    select
          encounter_type
        , count(1) as visits
    from {{ ref('core__encounter') }}
    group by encounter_type

)

, utilization__acute_inpatient as (

    select
          a.encounter_type
        , (visits / member_months * 12000) as visits_pkpy
    from visits a
    cross join member_months b
    where a.encounter_type in (
              'acute inpatient'
            , 'emergency department'
            , 'office visit'
            , 'urgent care'
            , 'dialysis'
            , 'inpatient skilled nursing'
            , 'home health'
        )

)

select
      'Utilization' as data_mart
    , encounter_type as table_name
    , visits_pkpy as field_value
from utilization__acute_inpatient
