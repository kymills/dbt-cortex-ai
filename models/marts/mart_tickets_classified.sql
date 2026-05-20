{{ config(
    materialized='incremental',
    unique_key='ticket_id'
) }}

select
    ticket_id,
    customer_id,
    created_at,
    subject,
    body,
    snowflake.cortex.classify_text(
        body,
        ['Billing Issue', 'Technical Support', 'Feature Request', 'Account Access', 'General Inquiry']
    )['label']::string as ticket_category,
    current_timestamp() as _enriched_at
from {{ ref('stg_support_tickets') }}

{% if is_incremental() %}
where created_at > (select max(created_at) from {{ this }})
{% endif %}
