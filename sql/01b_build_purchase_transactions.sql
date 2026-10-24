-- Run ONLY after reviewing the transaction diagnostics in 01_explore_events.sql.
-- If the same transaction_id has more than one distinct revenue value, stop and revise the
-- deduplication rule before relying on any revenue estimate.
-- This table avoids rescanning the raw purchase events separately in each sizing query.
CREATE OR REPLACE TABLE `YOUR_PROJECT.ga4_funnel.purchase_transactions` AS
SELECT
  ecommerce.transaction_id AS transaction_id,
  MAX(ecommerce.purchase_revenue_in_usd) AS transaction_revenue_usd,
  COUNT(*) AS source_purchase_event_rows,
  COUNT(DISTINCT ecommerce.purchase_revenue_in_usd) AS distinct_revenue_values
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
  AND ecommerce.transaction_id IS NOT NULL
  AND ecommerce.transaction_id != ''
  AND ecommerce.purchase_revenue_in_usd IS NOT NULL
GROUP BY transaction_id;

-- Post-build diagnostic: every transaction should have one distinct revenue value before MAX
-- is treated as deduplication. Investigate any row with distinct_revenue_values > 1.
SELECT
  COUNT(*) AS identified_transactions,
  COUNTIF(distinct_revenue_values > 1) AS transactions_with_inconsistent_revenue_values,
  SUM(transaction_revenue_usd) AS revenue_from_identified_transactions,
  AVG(transaction_revenue_usd) AS average_revenue_per_identified_transaction
FROM `YOUR_PROJECT.ga4_funnel.purchase_transactions`;
