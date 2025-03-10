{{ config(
     enabled = var('claims_enabled',var('clinical_enabled', False))
     | as_bool
   )
}}

with tuva_chronic_disease as (

    select
          person_id
        , condition
    from {{ ref('chronic_conditions__tuva_chronic_conditions_long') }}

)

, cms_chronic_disease as (

    select
          person_id
        , condition
        , condition_category
    from {{ ref('chronic_conditions__cms_chronic_conditions_long') }}

)

, total_patient_count as (

    select
          count(distinct person_id) as patient_count
    from {{  ref('core__patient') }}

)

, cardiovascular_disease_counts as (

    select
          count(distinct person_id) as cardiovascular_disease_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from cms_chronic_disease
    where lower(condition_category) = 'cardiovascular disease'

)

, hypertension_counts as (

    select
          count(distinct person_id) as hypertension_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from cms_chronic_disease
    where lower(condition) = 'hypertension'

)

, prostate_cancer_counts as (

    select
          count(distinct person_id) as prostate_cancer_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from cms_chronic_disease
    where lower(condition) like '%prostate%'

)

, liver_disease_counts as (

    select
        count(distinct person_id) as liver_disease_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from cms_chronic_disease
    where lower(condition) like '%liver disease%'

)

, type_1_diabetes_counts as (

    select
        count(distinct person_id) as type_1_diabetes_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'type 1 diabetes mellitus'

)

, type_2_diabetes_counts as (

    select
        count(distinct person_id) as type_2_diabetes_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'type 2 diabetes mellitus'

)

, obesity_counts as (

    select
        count(distinct person_id) as obesity_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'obesity'

)

, chronic_kidney_disease_counts as (

    select
        count(distinct person_id) as chronic_kidney_disease_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'chronic kidney disease'

)

, asthma_counts as (

    select
        count(distinct person_id) as asthma_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'asthma'

)

, copd_counts as (

    select
        count(distinct person_id) as copd_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where condition = 'Chronic Obstructive Pulmonary Disease'

)

, osteoporosis_counts as (

    select
        count(distinct person_id) as osteoporosis_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) like '%osteoporosis%'

)

, breast_cancer_counts as (

    select
        count(distinct person_id) as breast_cancer_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where condition = 'Breast Cancer'

)

, lung_cancer_counts as (

    select
        count(distinct person_id) as lung_cancer_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) like '%lung cancer%'

)

, colorectal_cancer_counts as (

    select
        count(distinct person_id) as colorectal_cancer_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where condition = 'Colorectal Cancer'

)

, arthritis_osteoarthritis_counts as (

    select
        count(distinct person_id) as osteoarthritis_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where lower(condition) = 'osteoarthritis'

)

, alzemiers_dementia_counts as (

    select
        count(distinct person_id) as alzemiers_dementia_count
        , coalesce((select patient_count from total_patient_count), 0) as patient_count
    from tuva_chronic_disease
    where condition in ('Alzheimer Disease', 'Dementia')

)


, final as (

    select 
          'Chronic Disease' as data_mart
        , 'Cardiovascular Disease' as table_name
        , cardiovascular_disease_count * 100 / NULLIF(patient_count, 0) as field_value
    from cardiovascular_disease_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Hypertension' as table_name
        , hypertension_count * 100 / NULLIF(patient_count, 0) as field_value
    from hypertension_counts 

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Prostate Cancer' as table_name
        , prostate_cancer_count * 100 / NULLIF(patient_count, 0) as field_value
    from prostate_cancer_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Liver Disease' as table_name
        , liver_disease_count * 100 / NULLIF(patient_count, 0) as field_value
    from liver_disease_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Type 1 Diabetes' as table_name
        , type_1_diabetes_count * 100 / NULLIF(patient_count, 0) as field_value
    from type_1_diabetes_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Type 2 Diabetes' as table_name
        , type_2_diabetes_count * 100 / NULLIF(patient_count, 0) as field_value
    from type_2_diabetes_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Obesity' as table_name
        , obesity_count * 100 / NULLIF(patient_count, 0) as field_value
    from obesity_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Chronic Kidney Disease' as table_name
        , chronic_kidney_disease_count * 100 / NULLIF(patient_count, 0) as field_value
    from chronic_kidney_disease_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Asthma' as table_name
        , asthma_count * 100 / NULLIF(patient_count, 0) as field_value
    from asthma_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'COPD' as table_name
        , copd_count * 100 / NULLIF(patient_count, 0) as field_value
    from copd_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Osteoporosis' as table_name
        , osteoporosis_count * 100 / NULLIF(patient_count, 0) as field_value
    from osteoporosis_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Breast Cancer' as table_name
        , breast_cancer_count * 100 / NULLIF(patient_count, 0) as field_value
    from breast_cancer_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Lung Cancer' as table_name
        , lung_cancer_count * 100 / NULLIF(patient_count, 0) as field_value
    from lung_cancer_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Colorectal Cancer' as table_name
        , colorectal_cancer_count * 100 / NULLIF(patient_count, 0) as field_value
    from colorectal_cancer_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Osteoarthritis' as table_name
        , osteoarthritis_count * 100 / NULLIF(patient_count, 0) as field_value
    from arthritis_osteoarthritis_counts

    union all

    select 
          'Chronic Disease' as data_mart
        , 'Alzemiers Dementia' as table_name
        , alzemiers_dementia_count * 100 / NULLIF(patient_count, 0) as field_value
    from alzemiers_dementia_counts

)

select
      data_mart
    , table_name
    , how to  as field_value
from final



