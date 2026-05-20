select
    note_id,
    agent_id,
    call_date::date as call_date,
    note_text
from {{ source('dbt_cortex_ai', 'call_notes') }}
