-- Semantic View for CX Agent
-- Run this after dbt models are built

CREATE OR REPLACE SEMANTIC VIEW DBT_CORTEX_AI.PUBLIC.CX_SEMANTIC_VIEW
  TABLES (
    DBT_CORTEX_AI.PUBLIC.MART_TICKETS_ENRICHED PRIMARY KEY (TICKET_ID) COMMENT = 'Support tickets with AI sentiment.',
    DBT_CORTEX_AI.PUBLIC.MART_TICKETS_CLASSIFIED PRIMARY KEY (TICKET_ID) COMMENT = 'Tickets classified by AI.',
    DBT_CORTEX_AI.PUBLIC.MART_REVIEWS_ANALYZED PRIMARY KEY (REVIEW_ID) COMMENT = 'Reviews analyzed for sentiment and complaints.',
    DBT_CORTEX_AI.PUBLIC.MART_CALL_NOTES_EXTRACTED PRIMARY KEY (NOTE_ID) COMMENT = 'Call notes with AI-extracted fields.',
    DBT_CORTEX_AI.PUBLIC.MART_WEEKLY_TICKET_THEMES COMMENT = 'Weekly ticket themes.'
  )
  RELATIONSHIPS (
    TICKETS_JOIN AS MART_TICKETS_ENRICHED(TICKET_ID) REFERENCES MART_TICKETS_CLASSIFIED(TICKET_ID)
  )
  FACTS (
    MART_TICKETS_ENRICHED.SENTIMENT_SCORE AS SENTIMENT_SCORE COMMENT = 'Sentiment from -1 to +1',
    MART_WEEKLY_TICKET_THEMES.TICKET_COUNT AS TICKET_COUNT COMMENT = 'Tickets per category per week',
    MART_WEEKLY_TICKET_THEMES.AVG_SENTIMENT AS AVG_SENTIMENT COMMENT = 'Avg sentiment per group'
  )
  DIMENSIONS (
    MART_TICKETS_ENRICHED.CUSTOMER_ID AS CUSTOMER_ID COMMENT = 'Customer ID',
    MART_TICKETS_ENRICHED.CREATED_AT AS CREATED_AT COMMENT = 'Ticket creation time',
    MART_TICKETS_ENRICHED.SUBJECT AS SUBJECT COMMENT = 'Ticket subject',
    MART_TICKETS_ENRICHED.SENTIMENT_BUCKET AS SENTIMENT_BUCKET COMMENT = 'positive, negative, neutral',
    MART_TICKETS_CLASSIFIED.TICKET_CATEGORY AS TICKET_CATEGORY COMMENT = 'AI-classified category',
    MART_REVIEWS_ANALYZED.PRODUCT_NAME AS PRODUCT_NAME COMMENT = 'Product name',
    MART_REVIEWS_ANALYZED.REVIEW_DATE AS REVIEW_DATE COMMENT = 'Review date',
    MART_REVIEWS_ANALYZED.WANTS_REFUND AS WANTS_REFUND COMMENT = 'Refund requested',
    MART_REVIEWS_ANALYZED.KEY_COMPLAINT AS KEY_COMPLAINT COMMENT = 'AI-extracted complaint',
    MART_REVIEWS_ANALYZED.URGENCY AS URGENCY COMMENT = 'high, medium, low',
    MART_REVIEWS_ANALYZED.OVERALL_SENTIMENT AS OVERALL_SENTIMENT COMMENT = 'positive, negative, mixed',
    MART_CALL_NOTES_EXTRACTED.AGENT_ID AS AGENT_ID COMMENT = 'Agent ID',
    MART_CALL_NOTES_EXTRACTED.CALL_DATE AS CALL_DATE COMMENT = 'Call date',
    MART_CALL_NOTES_EXTRACTED.CUSTOMER_NAME AS CUSTOMER_NAME COMMENT = 'Caller name',
    MART_CALL_NOTES_EXTRACTED.ISSUE_TYPE AS ISSUE_TYPE COMMENT = 'Call reason',
    MART_CALL_NOTES_EXTRACTED.RESOLUTION AS RESOLUTION COMMENT = 'Action taken',
    MART_CALL_NOTES_EXTRACTED.FOLLOW_UP_NEEDED AS FOLLOW_UP_NEEDED COMMENT = 'Follow-up needed',
    MART_WEEKLY_TICKET_THEMES.WEEK AS WEEK COMMENT = 'Week start',
    MART_WEEKLY_TICKET_THEMES.WEEKLY_THEMES AS WEEKLY_THEMES COMMENT = 'AI theme summary'
  )
  METRICS (
    MART_TICKETS_ENRICHED.TOTAL_TICKETS AS COUNT(TICKET_ID) COMMENT = 'Total tickets',
    MART_TICKETS_ENRICHED.AVG_TICKET_SENTIMENT AS AVG(SENTIMENT_SCORE) COMMENT = 'Average sentiment',
    MART_REVIEWS_ANALYZED.TOTAL_REVIEWS AS COUNT(REVIEW_ID) COMMENT = 'Total reviews',
    MART_REVIEWS_ANALYZED.REFUND_REQUESTS AS COUNT(CASE WHEN WANTS_REFUND THEN REVIEW_ID END) COMMENT = 'Refund requests',
    MART_CALL_NOTES_EXTRACTED.TOTAL_CALLS AS COUNT(NOTE_ID) COMMENT = 'Total calls'
  )
  COMMENT = 'CX analytics for education/test-prep. Tickets, reviews, calls, weekly trends. Built with dbt + Cortex AI.'
  AI_SQL_GENERATION 'Use CURRENT_DATE() for today. SENTIMENT_BUCKET for categorical, SENTIMENT_SCORE for numeric. Filter PRODUCT_NAME for products. Group AGENT_ID for agents.'
  AI_QUESTION_CATEGORIZATION 'Answers: ticket sentiment, product reviews, call center workload, weekly trends. Decline non-CX questions.';


-- Cortex Agent
-- Run this after the semantic view is created

CREATE OR REPLACE AGENT DBT_CORTEX_AI.PUBLIC.CX_AGENT
COMMENT = 'CX AI Analyst - answers questions about support tickets, product reviews, call center activity, and CX trends. Powered by dbt + Cortex AI.'
FROM SPECIFICATION
$$
models:
  orchestration: "auto"
orchestration:
  budget:
    seconds: 30
    tokens: 16000
instructions:
  response: "You are the Customer Experience data analyst for an education/test-prep company. You help CX managers, product teams, and executives understand support and feedback data.\n\nResponse guidelines:\n- Be concise and data-driven. Include specific numbers and percentages.\n- When presenting tabular data, format clearly with headers.\n- For sentiment, mention both the score and bucket (positive/negative/neutral).\n- When discussing products, name them explicitly.\n- For agent performance, include agent ID and metrics.\n- Proactively highlight concerning metrics (high negative sentiment, many refund requests).\n- Default time range is the last 30 days if not specified.\n- Round to 2 decimal places.\n"
  orchestration: "Use the CX Analytics tool for ALL questions about:\n- Support tickets: sentiment, categories, volume, trends\n- Product reviews: complaints, refund requests, urgency, product comparisons\n- Call center: agent workload, issue types, resolutions, follow-ups\n- Weekly trends: recurring themes, sentiment over time\n\nIf the user asks about something outside of customer experience or support, politely explain that you can only help with CX-related questions.\n"
  sample_questions:
    - question: "What percentage of tickets have negative sentiment?"
    - question: "Which products have the most refund requests?"
    - question: "Show me the busiest agents and their follow-up rates"
    - question: "What are the weekly ticket themes for Billing Issues?"
    - question: "How many high-urgency reviews came in this week?"
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "cx_analytics"
      description: "Use this tool to query customer experience data. Covers support tickets (sentiment, classification), product reviews (refund requests, complaints, urgency), call notes (issues, resolutions, follow-ups), and weekly trends. All data is AI-enriched via Cortex AI functions."
  - tool_spec:
      type: "data_to_chart"
      name: "data_to_chart"
      description: "Generates visualizations from query results."
tool_resources:
  cx_analytics:
    semantic_view: "DBT_CORTEX_AI.PUBLIC.CX_SEMANTIC_VIEW"
$$;
