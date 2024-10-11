{{ config(
    enabled = var('clinical_enabled', False)
) }}


SELECT
      m.data_source
    , coalesce(m.procedure_date,cast('1900-01-01' as date)) as SOURCE_DATE
    , 'PROCEDURE' AS table_name
    , 'Procedure ID' as drill_down_key
    , coalesce(procedure_id, 'NULL') AS drill_down_value
    , 'MODIFIER_1' as field_name
    , case when term.hcpcs is not null then 'valid'
           when m.modifier_1 is not null then 'invalid'
           else 'null'
    end as bucket_name
    , case when m.modifier_1 is not null and term.hcpcs is null
           then 'Modifier 1 does not join to Terminology hcpcs_level_2 table'
           else null end as invalid_reason
    , cast(modifier_1 as {{ dbt.type_string() }}) as field_value
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('procedure')}} m
left join {{ ref('terminology__hcpcs_level_2')}} term on m.modifier_1 = term.hcpcs