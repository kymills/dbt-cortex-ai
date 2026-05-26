{{ config(materialized='table') }}

select
    date_trunc('week', c.created_at) as week,
    ticket_category,
    count(*) as ticket_count,
    avg(e.sentiment_score) as avg_sentiment,
    snowflake.cortex.summarize(
        listagg(c.body, '\n---\n')
    ) as weekly_themes
from {{ ref('mart_tickets_classified') }} c
join {{ ref('mart_tickets_enriched') }} e
    on c.ticket_id = e.ticket_id
group by 1, 2
