-- Candidate gap-sizing analysis by first-touch acquisition medium.
-- This is first-touch user acquisition, not session attribution.
-- Requires the validated shared purchase_transactions table from 01b.
-- Benchmark groups need at least 1,000 sessions.
WITH channel_metrics AS (
  SELECT
    first_touch_medium,
    SUM(sessions) AS sessions,
    SUM(begin_checkout) AS checkout_sessions,
    SUM(purchase) AS purchase_sessions,
    SAFE_DIVIDE(SUM(purchase), SUM(begin_checkout)) AS checkout_to_purchase_rate
  FROM `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
  GROUP BY first_touch_medium
),
eligible AS (
  SELECT * FROM channel_metrics
  WHERE sessions >= 1000
),
benchmark AS (
  SELECT ARRAY_AGG(
    STRUCT(first_touch_medium, checkout_to_purchase_rate)
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
  c.first_touch_medium,
  c.sessions,
  c.checkout_sessions,
  c.purchase_sessions,
  c.checkout_to_purchase_rate,
  b.best.first_touch_medium AS benchmark_first_touch_medium,
  b.best.checkout_to_purchase_rate AS benchmark_rate,
  GREATEST(b.best.checkout_to_purchase_rate - c.checkout_to_purchase_rate, 0) AS rate_gap,
  GREATEST(b.best.checkout_to_purchase_rate - c.checkout_to_purchase_rate, 0) * c.checkout_sessions
    AS extra_orders_if_gap_fully_closed,
  a.avg_revenue_per_identified_transaction,
  a.identified_transactions,
  GREATEST(b.best.checkout_to_purchase_rate - c.checkout_to_purchase_rate, 0) * c.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.25 AS revenue_at_25pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - c.checkout_to_purchase_rate, 0) * c.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.50 AS revenue_at_50pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - c.checkout_to_purchase_rate, 0) * c.checkout_sessions
    * a.avg_revenue_per_identified_transaction AS revenue_at_100pct_gap_closure
FROM channel_metrics AS c
CROSS JOIN benchmark AS b
CROSS JOIN average_revenue AS a
WHERE c.sessions >= 1000
ORDER BY revenue_at_50pct_gap_closure DESC;

-- Revenue values are scenarios, not forecasts. Check transaction ID duplication and missingness first.
-- Do not claim the channel caused the difference. traffic_source.medium is first-touch acquisition.
