{{ config(
    enabled = var('claims_enabled', False)
) }}

with acute_inpatient as (

    select
          length_of_stay
        , discharge_disposition_code
        , encounter_end_date
        , paid_amount
    from {{ ref('core__encounter') }}
    where encounter_type = 'acute inpatient'

)

, alos_cte as (

    select
      avg(length_of_stay) as alos
from acute_inpatient

)

, mortality_flag_cte as (

    select
        case
            when cast(discharge_disposition_code as {{ dbt.type_string() }}) = '20' then 1
            else 0
        end as mortality_flag
    from acute_inpatient
    where discharge_disposition_code is not null
    and encounter_end_date is not null

)

, mortality_rate_cte as (

    select
      sum(mortality_flag) / count(1) as mortality_rate
    from mortality_flag_cte

)

, readmit as (
    
    select
          sum(case 
                when index_admission_flag = 1
                    then 1
                else 0
            end) as index_admissions
        , sum(case 
                when index_admission_flag = 1 and unplanned_readmit_30_flag = 1 
                    then 1 
                else 0
            end) as readmissions
    from {{ ref('readmissions__readmission_summary') }}
    
)

, readmission_rate_cte as (

    select 
        case 
            when index_admissions = 0
                then 0 
            else readmissions / index_admissions 
        end as readmission_rate
    from readmit

)

, cost_per_visit_cte as (

    select
          sum(paid_amount)/count(1) as cost_per_visit
    from acute_inpatient

)

, cms_hcc__risk_score as (

    select
          avg(payment_risk_score) as risk_score
    from {{ ref('cms_hcc__patient_risk_scores') }}

)

, final as (

    select
          'Acute Inpatient' as data_mart
        , 'Acute IP ALOS' as table_name
        , alos as field_value 
    from alos_cte

   union all

    select
          'Acute Inpatient' as data_mart
        , 'Acute IP Mortality Rate' as table_name
        , mortality_rate as field_value 
    from mortality_rate_cte

    union all

    select
          'Acute Inpatient' as data_mart
        , 'Acute IP Readmission Rate' as table_name
        , readmission_rate as field_value
    from readmission_rate_cte 

    union all

    select
          'Acute Inpatient' as data_mart
        , 'Acute IP Cost Per Visit' as table_name
        , cost_per_visit as field_value
    from cost_per_visit_cte

    union all

    select
          'CMS-HCC' as data_mart
        , 'CMS-HCC Avg. Risk Score' as table_name
        , risk_score as field_value
    from cms_hcc__risk_score

)

select
      data_mart
    , table_name
    , field_value
from final
