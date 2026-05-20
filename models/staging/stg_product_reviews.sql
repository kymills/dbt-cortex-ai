select
    review_id,
    product_name,
    review_date::date as review_date,
    review_text
from {{ source('dbt_cortex_ai', 'product_reviews') }}
