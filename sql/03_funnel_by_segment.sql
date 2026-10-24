-- Summary table by device and first-touch acquisition medium.
-- The cumulative counting rule deliberately ignores timestamp order: each stage requires all prior flags.
CREATE OR REPLACE TABLE `YOUR_PROJECT.ga4_funnel.funnel_by_segment` AS
SELECT
  device_category,
  first_touch_medium,
  COUNT(*) AS sessions,
  COUNTIF(did_view_item = 1) AS view_item,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1) AS add_to_cart,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1
          AND did_begin_checkout = 1) AS begin_checkout,
  COUNTIF(did_view_item = 1 AND did_add_to_cart = 1
          AND did_begin_checkout = 1 AND did_purchase = 1) AS purchase,
  SUM(IF(did_purchase = 1, revenue_usd, 0)) AS revenue_usd
FROM `YOUR_PROJECT.ga4_funnel.sessions`
GROUP BY device_category, first_touch_medium;
