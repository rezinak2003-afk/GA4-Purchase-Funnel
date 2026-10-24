-- Project 1: GA4 Purchase Funnel Analysis
-- Run each section separately and record actual results in docs/data_notes.md.
-- Always review the bytes-processed estimate before running a query.

-- A) Which events exist and how common are they?
SELECT
  event_name,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_name
ORDER BY events DESC;

-- B) Which keys live inside event_params?
SELECT
  ep.key,
  COUNT(*) AS occurrences
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(event_params) AS ep
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY ep.key
ORDER BY occurrences DESC
LIMIT 50;

-- C) Device categories and first-touch acquisition media.
-- IMPORTANT: traffic_source is first-touch, not the current session source.
SELECT
  device.category AS device_category,
  traffic_source.medium AS first_touch_medium,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY 1, 2
ORDER BY users DESC;

-- D) Daily event volume. Check for gaps and spikes.
SELECT
  event_date,
  COUNT(*) AS events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_date
ORDER BY event_date;

-- E) Confirm the actual event_date coverage.
SELECT
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(*) AS total_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

-- F) PURCHASE TRANSACTION DIAGNOSTIC.
-- First inspect the events_* schema and confirm ecommerce.transaction_id exists.
-- Do not trust summed purchase revenue until missing/duplicate transaction IDs are understood.
SELECT
  COUNT(*) AS purchase_events,
  COUNTIF(ecommerce.transaction_id IS NULL OR ecommerce.transaction_id = '') AS missing_transaction_id_events,
  COUNT(DISTINCT IF(ecommerce.transaction_id IS NOT NULL AND ecommerce.transaction_id != '', ecommerce.transaction_id, NULL)) AS distinct_nonempty_transaction_ids
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase';

-- G) List duplicate non-null transaction IDs (if the transaction_id field exists).
SELECT
  ecommerce.transaction_id AS transaction_id,
  COUNT(*) AS purchase_event_rows,
  COUNT(DISTINCT ecommerce.purchase_revenue_in_usd) AS distinct_revenue_values,
  MIN(ecommerce.purchase_revenue_in_usd) AS min_event_revenue_usd,
  MAX(ecommerce.purchase_revenue_in_usd) AS max_event_revenue_usd,
  SUM(ecommerce.purchase_revenue_in_usd) AS summed_event_revenue_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
  AND ecommerce.transaction_id IS NOT NULL
  AND ecommerce.transaction_id != ''
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY purchase_event_rows DESC;
