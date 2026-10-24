-- Candidate gap-sizing analysis for device checkout completion.
-- Run only after transaction-ID diagnostics, `01b_build_purchase_transactions.sql`, session sanity checks, and funnel review.
-- Eligible device benchmarks use at least 1,000 sessions, using the guide's
-- anti-small-sample rule. If no device qualifies, adjust the analysis only with a documented rationale.
WITH device_metrics AS (
  SELECT
    device_category,
    SUM(sessions) AS sessions,
    SUM(begin_checkout) AS checkout_sessions,
    SUM(purchase) AS purchase_sessions,
    SAFE_DIVIDE(SUM(purchase), SUM(begin_checkout)) AS checkout_to_purchase_rate
  FROM `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
  GROUP BY device_category
),
eligible AS (
  SELECT *
  FROM device_metrics
  WHERE sessions >= 1000
    AND device_category IS NOT NULL
),
benchmark AS (
  SELECT ARRAY_AGG(
    STRUCT(device_category, checkout_to_purchase_rate)
    ORDER BY checkout_to_purchase_rate DESC
    LIMIT 1
  )[SAFE_OFFSET(0)] AS best
  FROM eligible
),
average_revenue AS (
  SELECT
    AVG(transaction_revenue_usd) AS avg_revenue_per_identified_transaction,
    COUNT(*) AS identified_transactions
  FROM `YOUR_PROJECT.ga4_funnel.purchase_transactions`
)
SELECT
  d.device_category,
  d.sessions,
  d.checkout_sessions,
  d.purchase_sessions,
  d.checkout_to_purchase_rate,
  b.best.device_category AS benchmark_device_category,
  b.best.checkout_to_purchase_rate AS benchmark_rate,
  GREATEST(b.best.checkout_to_purchase_rate - d.checkout_to_purchase_rate, 0) AS rate_gap,
  GREATEST(b.best.checkout_to_purchase_rate - d.checkout_to_purchase_rate, 0) * d.checkout_sessions
    AS extra_orders_if_gap_fully_closed,
  a.avg_revenue_per_identified_transaction,
  a.identified_transactions,
  GREATEST(b.best.checkout_to_purchase_rate - d.checkout_to_purchase_rate, 0) * d.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.25 AS revenue_at_25pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - d.checkout_to_purchase_rate, 0) * d.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.50 AS revenue_at_50pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - d.checkout_to_purchase_rate, 0) * d.checkout_sessions
    * a.avg_revenue_per_identified_transaction AS revenue_at_100pct_gap_closure
FROM device_metrics AS d
CROSS JOIN benchmark AS b
CROSS JOIN average_revenue AS a
WHERE d.sessions >= 1000
ORDER BY revenue_at_50pct_gap_closure DESC;

-- Important: this is an illustrative opportunity-sizing method, not a forecast.
-- The query uses identifiable transactions for average revenue; report the missing-ID count from
-- the diagnostic and do not treat this average as complete if missing IDs are material.
-- Review transaction_id duplication before trusting the deduplication assumptions. Report
-- 25%, 50%, and 100% scenarios. A device gap indicates where to investigate and test; it does
-- not prove the device experience is broken.
