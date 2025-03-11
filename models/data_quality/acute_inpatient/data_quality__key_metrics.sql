{{ config(
    enabled = var('claims_enabled', False)
) }}

with financial as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_financial') }}

)

, utilization as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_utilization') }}

)

, acute_inpatient__cms_hcc as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_aip_cms_hcc') }}

)

, patient_sex_and_age as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_patient_sex_and_age') }}

)

, chronic_disease as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_chronic_disease') }}

)

, acute_events as (

    select
          data_mart
        , table_name
        , field_value
    from {{ ref('data_quality__key_metrics_acute_events') }}

)

, final as (

    select * from financial

    union all

    select * from utilization

    union all

    select * from acute_inpatient__cms_hcc

    union all

    select * from patient_sex_and_age

    union all

    select * from chronic_disease

    union all

    select * from acute_events

)

select
      data_mart
    , table_name
    , field_value
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from final
