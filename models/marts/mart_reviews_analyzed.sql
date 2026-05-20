{{ config(
    materialized='incremental',
    unique_key='review_id'
) }}

select
    review_id,
    product_name,
    review_date,
    review_text,
    try_parse_json(
        snowflake.cortex.complete(
            'llama3.1-70b',
            'Return ONLY valid JSON, no markdown, no code blocks. Fields: wants_refund (bool), key_complaint (string or null), urgency (high/medium/low), overall_sentiment (positive/negative/mixed). Review: ' || review_text
        )
    ) as analysis,
    analysis:"wants_refund"::boolean as wants_refund,
    analysis:"key_complaint"::string as key_complaint,
    analysis:"urgency"::string as urgency,
    analysis:"overall_sentiment"::string as overall_sentiment,
    current_timestamp() as _enriched_at
from {{ ref('stg_product_reviews') }}

{% if is_incremental() %}
where review_date > (select max(review_date) from {{ this }})
{% endif %}
