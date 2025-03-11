{{ config(
    enabled = var('claims_enabled', False)
) }}

with financial__paid as (

    select
          sum(total_paid)/count(1) as total_pmpm
        , sum(medical_paid)/count(1) as medical_pmpm
        , sum(inpatient_paid)/count(1) as inpatient_pmpm
        , sum(outpatient_paid)/count(1) as outpatient_pmpm
        , sum(office_based_paid)/count(1) as office_based_pmpm
        , sum(ancillary_paid)/count(1) as ancillary_pmpm
        , sum(other_paid)/count(1) as other_pmpm
        , sum(pharmacy_paid)/count(1) as pharmacy_pmpm
    from {{ ref('financial_pmpm__pmpm_prep') }}

)

{# select 
    financial_category, 
    pmpm_value
from {{ dbt_utils.unpivot(
    relation= ref('financial_pmpm__pmpm_prep'),
    cast_to="numeric",
    field_name="financial_category",
    value_name="pmpm_value"
) }} #}

, final as (

    select
        'Financial' as data_mart
        , 'Total PMPM' as table_name
        , total_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Medical PMPM' as table_name
        , medical_pmpm as field_value
    from financial__paid
    
    union all

    select
        'Financial' as data_mart
        , 'Inpatient PMPM' as table_name
        , inpatient_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Outpatient PMPM' as table_name
        , outpatient_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Office Visit PMPM' as table_name
        , office_based_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Ancillary PMPM' as table_name
        , ancillary_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Other PMPM' as table_name
        , other_pmpm as field_value
    from financial__paid

    union all

    select
        'Financial' as data_mart
        , 'Pharmacy PMPM' as table_name
        , pharmacy_pmpm as field_value
    from financial__paid

)

select
      data_mart
    , table_name
    , field_value
from final