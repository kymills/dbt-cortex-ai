{{ config(
    materialized='incremental',
    unique_key='note_id'
) }}

select
    note_id,
    agent_id,
    call_date,
    note_text,
    snowflake.cortex.extract_answer(
        note_text,
        'What is the customer name?'
    )[0]['answer']::string as customer_name,
    snowflake.cortex.extract_answer(
        note_text,
        'What is the issue or reason for the call?'
    )[0]['answer']::string as issue_type,
    snowflake.cortex.extract_answer(
        note_text,
        'What was the resolution or action taken?'
    )[0]['answer']::string as resolution,
    snowflake.cortex.extract_answer(
        note_text,
        'Is follow up needed?'
    )[0]['answer']::string as follow_up_needed,
    current_timestamp() as _enriched_at
from {{ ref('stg_call_notes') }}

{% if is_incremental() %}
where call_date > (select max(call_date) from {{ this }})
{% endif %}
