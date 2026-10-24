-- Run after sql/02_build_sessions.sql. Record outputs in docs/data_notes.md.

-- A) Session count and core funnel-skip checks.
SELECT
  COUNT(*) AS sessions,
  COUNT(DISTINCT session_key) AS distinct_sessions,
  COUNT(DISTINCT user_pseudo_id) AS users,
  SUM(did_purchase) AS purchase_sessions,
  COUNTIF(did_purchase = 1 AND did_add_to_cart = 0) AS purchase_without_cart,
  COUNTIF(did_purchase = 1 AND did_view_item = 0) AS purchase_without_view_item,
  COUNTIF(did_begin_checkout = 1 AND did_add_to_cart = 0) AS checkout_without_cart
FROM `YOUR_PROJECT.ga4_funnel.sessions`;

-- B) Count raw events excluded because the session identifier or user key is missing.
SELECT
  COUNTIF((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') IS NULL)
    AS events_with_null_ga_session_id,
  COUNTIF(user_pseudo_id IS NULL) AS events_with_null_user_pseudo_id,
  COUNT(*) AS raw_events_in_scope
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

-- C) Distribution of funnel flags, including sessions that skip earlier steps.
SELECT
  did_view_item,
  did_add_to_cart,
  did_begin_checkout,
  did_purchase,
  COUNT(*) AS sessions
FROM `YOUR_PROJECT.ga4_funnel.sessions`
GROUP BY 1, 2, 3, 4
ORDER BY sessions DESC;

-- Required check: sessions must equal distinct_sessions. If not, resolve the key/grouping issue first.
