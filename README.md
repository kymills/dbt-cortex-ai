# dbt + Cortex AI Functions

A dbt project demonstrating how to embed Snowflake Cortex AI functions directly inside dbt models as SQL transformations.

## Cortex AI Functions Demonstrated

| Model | Function | Description |
|-------|----------|-------------|
| `mart_tickets_enriched` | `snowflake.cortex.sentiment()` | Sentiment analysis on support tickets |
| `mart_tickets_classified` | `snowflake.cortex.classify_text()` | Auto-categorization into support categories |
| `mart_call_notes_extracted` | `snowflake.cortex.extract_answer()` | Structured field extraction from free-text notes |
| `mart_reviews_analyzed` | `snowflake.cortex.complete()` | Multi-field JSON analysis with llama3.1-70b |
| `mart_weekly_ticket_themes` | `snowflake.cortex.summarize()` | Weekly theme summarization across ticket groups |

## Project Structure

```
├── models/
│   ├── staging/
│   │   ├── _sources.yml
│   │   ├── schema.yml
│   │   ├── stg_support_tickets.sql
│   │   ├── stg_call_notes.sql
│   │   └── stg_product_reviews.sql
│   └── marts/
│       ├── schema.yml
│       ├── mart_tickets_enriched.sql
│       ├── mart_tickets_classified.sql
│       ├── mart_call_notes_extracted.sql
│       ├── mart_reviews_analyzed.sql
│       └── mart_weekly_ticket_themes.sql
├── seeds/
│   ├── support_tickets.csv
│   ├── call_notes.csv
│   └── product_reviews.csv
├── dbt_project.yml
├── profiles.yml
└── packages.yml
```

## Setup

1. Update `profiles.yml` with your Snowflake account and credentials
2. Create the database:
   ```sql
   CREATE DATABASE IF NOT EXISTS DBT_CORTEX_AI;
   ```
3. Install dependencies:
   ```
   dbt deps
   ```
4. Load seed data:
   ```
   dbt seed
   ```
5. Run the project:
   ```
   dbt build
   ```

## Requirements

- Snowflake account with Cortex AI functions enabled
- `dbt-snowflake` adapter
- Warehouse with access to Cortex LLM functions

## Key Patterns

- **Incremental models** — AI functions cost credits per call; avoid reprocessing with incremental materialization
- **`try_parse_json`** — LLMs don't always return valid JSON; wrap defensively
- **Prompt engineering** — "Return ONLY valid JSON, no markdown" prevents markdown-wrapped responses
- **Accepted values tests** — Validate AI outputs against known category lists
- **Tag-based job separation** — Tag AI models with `ai_enrichment` to run them in a separate dbt job
