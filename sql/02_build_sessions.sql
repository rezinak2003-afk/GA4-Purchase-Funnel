-- Build one row per GA4 session.
-- Replace YOUR_PROJECT with your Google Cloud project ID.
-- Dataset ga4_funnel must be in the US location.
-- Inspect the source schema first to confirm the parameter and revenue field paths.

CREATE OR REPLACE TABLE `YOUR_PROJECT.ga4_funnel.sessions` AS
WITH flat AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value
     FROM UNNEST(event_params)
     WHERE key = 'ga_session_id') AS ga_session_id,
    (SELECT value.string_value
     FROM UNNEST(event_params)
     WHERE key = 'page_location') AS page_location,
    event_name,
    event_timestamp,
    COALESCE(device.category, 'Other/unknown') AS device_category,
    CASE
      WHEN traffic_source.source IS NULL
        OR LOWER(TRIM(traffic_source.source)) IN ('(not set)', '(data deleted)', '<other>')
        THEN 'Other/unknown'
      ELSE traffic_source.source
    END AS first_touch_source,
    CASE
      WHEN traffic_source.medium IS NULL
        OR LOWER(TRIM(traffic_source.medium)) IN ('(not set)', '(data deleted)', '<other>')
        THEN 'Other/unknown'
      ELSE traffic_source.medium
    END AS first_touch_medium,
    ecommerce.purchase_revenue_in_usd AS revenue_usd
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),
sessions AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS session_key,
    user_pseudo_id,
    MIN(event_timestamp) AS session_start_ts,
    ANY_VALUE(device_category) AS device_category,
    ANY_VALUE(first_touch_source) AS first_touch_source,
    ANY_VALUE(first_touch_medium) AS first_touch_medium,
    ARRAY_AGG(
      IF(event_name = 'page_view', page_location, NULL)
      IGNORE NULLS ORDER BY event_timestamp LIMIT 1
    )[SAFE_OFFSET(0)] AS landing_page,
    MAX(IF(event_name = 'view_item', 1, 0)) AS did_view_item,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS did_add_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS did_begin_checkout,
    MAX(IF(event_name = 'purchase', 1, 0)) AS did_purchase,
    SUM(IF(event_name = 'purchase', revenue_usd, 0)) AS revenue_usd
  FROM flat
  WHERE ga_session_id IS NOT NULL
    AND user_pseudo_id IS NOT NULL
  GROUP BY session_key, user_pseudo_id
)
SELECT * FROM sessions;
