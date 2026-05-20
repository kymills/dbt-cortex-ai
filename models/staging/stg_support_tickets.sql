select
    ticket_id,
    customer_id,
    created_at::timestamp as created_at,
    subject,
    body
from {{ source('dbt_cortex_ai', 'support_tickets') }}
