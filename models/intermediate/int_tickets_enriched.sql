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
    snowflake.cortex.sentiment(body) as sentiment_score,
    case
        when snowflake.cortex.sentiment(body) >= 0.3 then 'positive'
        when snowflake.cortex.sentiment(body) <= -0.3 then 'negative'
        else 'neutral'
    end as sentiment_bucket,
    current_timestamp() as _enriched_at
from {{ ref('stg_support_tickets') }}

{% if is_incremental() %}
where created_at > (select max(created_at) from {{ this }})
{% endif %}
