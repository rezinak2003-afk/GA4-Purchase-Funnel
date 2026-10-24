-- A) Conversion by device category.
SELECT
  device_category,
  SUM(sessions) AS sessions,
  SUM(view_item) AS view_item,
  SUM(add_to_cart) AS add_to_cart,
  SUM(begin_checkout) AS begin_checkout,
  SUM(purchase) AS purchase,
  SAFE_DIVIDE(SUM(view_item), SUM(sessions)) AS session_to_view,
  SAFE_DIVIDE(SUM(add_to_cart), SUM(view_item)) AS view_to_cart,
  SAFE_DIVIDE(SUM(begin_checkout), SUM(add_to_cart)) AS cart_to_checkout,
  SAFE_DIVIDE(SUM(purchase), SUM(begin_checkout)) AS checkout_to_purchase,
  SAFE_DIVIDE(SUM(purchase), SUM(sessions)) AS overall_conversion,
  SUM(revenue_usd) AS revenue_usd
FROM `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
GROUP BY device_category
ORDER BY sessions DESC;

-- B) Conversion by first-touch acquisition medium. Label the result as first-touch.
SELECT
  first_touch_medium,
  SUM(sessions) AS sessions,
  SUM(view_item) AS view_item,
  SUM(add_to_cart) AS add_to_cart,
  SUM(begin_checkout) AS begin_checkout,
  SUM(purchase) AS purchase,
  SAFE_DIVIDE(SUM(view_item), SUM(sessions)) AS session_to_view,
  SAFE_DIVIDE(SUM(add_to_cart), SUM(view_item)) AS view_to_cart,
  SAFE_DIVIDE(SUM(begin_checkout), SUM(add_to_cart)) AS cart_to_checkout,
  SAFE_DIVIDE(SUM(purchase), SUM(begin_checkout)) AS checkout_to_purchase,
  SAFE_DIVIDE(SUM(purchase), SUM(sessions)) AS overall_conversion,
  SUM(revenue_usd) AS revenue_usd
FROM `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
GROUP BY first_touch_medium
ORDER BY sessions DESC;
