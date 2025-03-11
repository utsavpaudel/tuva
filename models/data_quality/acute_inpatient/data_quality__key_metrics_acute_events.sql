{{ config(
    enabled = var('claims_enabled', False)
) }}

with cms__chronic_conditions as (

    select
          person_id
        , condition
    from {{ ref('chronic_conditions__cms_chronic_conditions_long') }}

)

, tuva__chronic_conditions as (

    select
          person_id
        , condition
    from {{ ref('chronic_conditions__tuva_chronic_conditions_long') }}

)

, member_months as (

    select
        count(1) as member_months
    from {{ ref('financial_pmpm__pmpm_prep') }}

)

, stroke_events as (

    select
          person_id
        , condition
    from cms__chronic_conditions
    where lower(condition) like '%stroke%'
    
    union all

    select
          person_id
        , condition
    from tuva__chronic_conditions
    where lower(condition) like '%stroke%'

)

, myocardial_infarction_events as (

    select
          person_id
        , condition
    from cms__chronic_conditions
    where lower(condition) like '%myocardial infarction%'
    
    union all

    select
          person_id
        , condition
    from tuva__chronic_conditions
    where lower(condition) like '%myocardial infarction%'

)

, number_count as (

    select
        count(distinct person_id) as personcount
        , 'Stroke' as table_name
    from stroke_events

    union all

    select
        count(distinct person_id) as personcount
        , 'Myocardial Infarction' as table_name
    from myocardial_infarction_events

)

, acute_events as (

    select
          (personcount / member_months * 12000) as acute_events_pkpy
        , table_name
    from number_count a
    cross join member_months b

)

select
      'Acute Events' as data_mart
    , table_name as table_name
    , acute_events_pkpy as field_value
from acute_events
