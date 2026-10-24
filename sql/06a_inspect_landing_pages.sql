-- A) Inspect the top landing paths before defining page types.
SELECT
  REGEXP_EXTRACT(landing_page, r'https?://[^/]+(/[^?#]*)') AS landing_path,
  COUNT(*) AS sessions,
  COUNTIF(did_purchase = 1) AS purchase_sessions,
  SAFE_DIVIDE(COUNTIF(did_purchase = 1), COUNT(*)) AS raw_session_purchase_rate
FROM `YOUR_PROJECT.ga4_funnel.sessions`
GROUP BY landing_path
ORDER BY sessions DESC
LIMIT 50;
