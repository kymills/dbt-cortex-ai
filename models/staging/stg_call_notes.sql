select
    note_id,
    agent_id,
    call_date::date as call_date,
    note_text
from {{ ref('call_notes') }}
