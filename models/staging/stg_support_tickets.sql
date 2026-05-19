select
    ticket_id,
    customer_id,
    created_at::timestamp as created_at,
    subject,
    body
from {{ ref('support_tickets') }}
