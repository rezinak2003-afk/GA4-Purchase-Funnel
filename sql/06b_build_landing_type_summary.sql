-- Build landing-type summary ONLY after inspecting the output from 06a.
-- B) After inspecting the output above, adapt these example patterns to the real URLs.
-- Do not blindly copy these rules; check the top paths and adjust the CASE expression.
CREATE OR REPLACE TABLE `YOUR_PROJECT.ga4_funnel.landing_type_summary` AS
WITH session_paths AS (
  SELECT
    *,
    REGEXP_EXTRACT(landing_page, r'https?://[^/]+(/[^?#]*)') AS landing_path
  FROM `YOUR_PROJECT.ga4_funnel.sessions`
),
classified AS (
  SELECT
    *,
    CASE
      WHEN landing_path IS NULL THEN 'Other/unknown'
      WHEN landing_path IN ('', '/') THEN 'Home'
      WHEN REGEXP_CONTAINS(landing_path, r'(?i)basket|checkout|signin') THEN 'Basket / sign-in'
      WHEN REGEXP_CONTAINS(landing_path, r'(?i)store|shop\+by|apparel|lifestyle') THEN 'Category'
      ELSE 'Other (inspect these)'
    END AS landing_type
  FROM session_paths
)
SELECT
  landing_type,
  COUNT(*) AS sessions,
  COUNTIF(did_view_item = 1) AS view_item_sessions,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1) AS add_to_cart_sessions,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1
          AND did_begin_checkout = 1) AS begin_checkout_sessions,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1
          AND did_begin_checkout = 1 AND did_purchase = 1) AS cumulative_purchase_sessions,
  COUNTIF(did_purchase = 1) AS all_purchase_sessions,
  SAFE_DIVIDE(
    COUNTIF(did_view_item = 1 AND did_add_to_cart = 1
            AND did_begin_checkout = 1 AND did_purchase = 1),
    COUNT(*)
  ) AS cumulative_session_to_purchase_conversion
FROM classified
GROUP BY landing_type
HAVING COUNT(*) >= 1000
ORDER BY sessions DESC;

-- The first query's raw purchase rate is diagnostic only. The grouped analysis reports the
-- cumulative headline conversion alongside all purchase sessions so skipped-stage purchases
-- remain visible. Event flags are not timestamp-ordered. Tiny page groups must not be ranked.
