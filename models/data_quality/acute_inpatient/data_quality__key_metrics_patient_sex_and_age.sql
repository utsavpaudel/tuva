{{ config(
     enabled = var('claims_enabled',var('clinical_enabled', False))
     | as_bool
   )
}}

with patient as (

    select 
          person_id
        , sex
        , birth_date
        , cast(substring('{{ var('tuva_last_run')}}',1,10) as date) as tuva_last_run_date
    from {{ ref('core__patient') }}

)

, total_patient_count as (

    select count(distinct person_id) as patient_count
    from patient

)

, patient_counts as (

    select 
          count(distinct person_id) as patient_count
        , count(distinct
            case 
                when lower(sex) = 'male' then person_id
            end ) as male_count
        , count(distinct
            case 
                when lower(sex) = 'female' then person_id
            end ) as female_count
        , count(distinct
            case 
                when lower(sex) = 'unknown' then person_id
            end ) as unknown_count
    from patient

)

, patient_sex_perc as (

    select
          male_count * 100 / NULLIF(patient_count, 0) AS male_perc
        , female_count * 100 / NULLIF(patient_count, 0) AS female_perc
        , unknown_count * 100 / NULLIF(patient_count, 0) AS unknown_perc
    from patient_counts

)

, age_groups AS (
    -- Define all possible age groups
    SELECT '0-1' AS age_group
    UNION ALL
    SELECT '1-14'
    UNION ALL
    SELECT '15-24'
    UNION ALL
    SELECT '25-34'
    UNION ALL
    SELECT '35-44'
    UNION ALL
    SELECT '45-54'
    UNION ALL
    SELECT '55-64'
    UNION ALL
    SELECT '65-74'
    UNION ALL
    SELECT '75-84'
    UNION ALL
    SELECT '85-94'
    UNION ALL
    SELECT '95+'
    
)

, patient_age_group as (

    select 
          person_id
        , cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) as age
        , cast(
            CASE
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 1 THEN '0-1'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 15 THEN '1-14'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 25 THEN '15-24'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 35 THEN '25-34'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 45 THEN '35-44'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 55 THEN '45-54'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 65 THEN '55-64'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 75 THEN '65-74'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 85 THEN '75-84'
                WHEN cast(floor({{ datediff('birth_date', 'tuva_last_run_date', 'hour') }} / 8760.0) as {{ dbt.type_int() }} ) < 95 THEN '85-94'
                ELSE '95+'
            END as {{ dbt.type_string() }}
        ) AS age_group
    from patient

)

, patient_age_group_counts as (

    select 
          age_group
        , ( select count(distinct person_id) from patient ) as patient_count
        , count(distinct person_id) as patient_count_for_age_group
    from patient_age_group
    group by age_group

)

, all_age_group_counts as (

    select 
          ag.age_group as age_group
        , coalesce((select patient_count from total_patient_count), 0) as patient_count 
        , coalesce(pag.patient_count_for_age_group, 0) as patient_count_for_age_group
    from age_groups as ag
    left join patient_age_group_counts as pag
        on ag.age_group = pag.age_group

)

, patient_age_group_perc as (
    
    select
          'Patient Age' as data_mart
        , age_group as table_name
        , patient_count_for_age_group * 100 / NULLIF(patient_count, 0) as field_value
    from all_age_group_counts

)

, final as (
    
    select 
        'Patient Sex' AS data_mart, '% Male' AS table_name, male_perc AS field_value
    from patient_sex_perc

    union all

    select 'Patient Sex' AS data_mart, '% Female' AS table_name, female_perc AS field_value
    from patient_sex_perc

    union all

    select 'Patient Sex' AS data_mart, '% Unknown' AS table_name, unknown_perc AS field_value
    from patient_sex_perc

    union all 

    select * from patient_age_group_perc

)

select 
      data_mart
    , table_name
    , round(cast(field_value as {{ dbt.type_numeric() }}), 2 ) as field_value
from final