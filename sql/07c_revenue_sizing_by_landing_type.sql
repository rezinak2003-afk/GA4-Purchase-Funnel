-- Candidate gap-sizing analysis by landing-page type.
-- Requires `06b_build_landing_type_summary.sql` after inspecting real paths from 06a and updating the CASE patterns. Also requires the validated `purchase_transactions` table from 01b.
-- Use a minimum of 1,000 sessions per landing type; benchmark candidate groups must also meet that threshold.
WITH landing_metrics AS (
  SELECT
    landing_type,
    SUM(sessions) AS sessions,
    SUM(begin_checkout_sessions) AS checkout_sessions,
    SUM(cumulative_purchase_sessions) AS purchase_sessions,
    SAFE_DIVIDE(SUM(cumulative_purchase_sessions), SUM(begin_checkout_sessions))
      AS checkout_to_purchase_rate
  FROM `YOUR_PROJECT.ga4_funnel.landing_type_summary`
  GROUP BY landing_type
),
eligible AS (
  SELECT * FROM landing_metrics
  WHERE sessions >= 1000
),
benchmark AS (
  SELECT ARRAY_AGG(
    STRUCT(landing_type, checkout_to_purchase_rate)
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
  l.landing_type,
  l.sessions,
  l.checkout_sessions,
  l.purchase_sessions,
  l.checkout_to_purchase_rate,
  b.best.landing_type AS benchmark_landing_type,
  b.best.checkout_to_purchase_rate AS benchmark_rate,
  GREATEST(b.best.checkout_to_purchase_rate - l.checkout_to_purchase_rate, 0) AS rate_gap,
  GREATEST(b.best.checkout_to_purchase_rate - l.checkout_to_purchase_rate, 0) * l.checkout_sessions
    AS extra_orders_if_gap_fully_closed,
  a.avg_revenue_per_identified_transaction,
  a.identified_transactions,
  GREATEST(b.best.checkout_to_purchase_rate - l.checkout_to_purchase_rate, 0) * l.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.25 AS revenue_at_25pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - l.checkout_to_purchase_rate, 0) * l.checkout_sessions
    * a.avg_revenue_per_identified_transaction * 0.50 AS revenue_at_50pct_gap_closure,
  GREATEST(b.best.checkout_to_purchase_rate - l.checkout_to_purchase_rate, 0) * l.checkout_sessions
    * a.avg_revenue_per_identified_transaction AS revenue_at_100pct_gap_closure
FROM landing_metrics AS l
CROSS JOIN benchmark AS b
CROSS JOIN average_revenue AS a
WHERE l.sessions >= 1000
ORDER BY revenue_at_50pct_gap_closure DESC;

-- This estimates an opportunity, not a forecast. If transaction IDs have inconsistent duplicate values,
-- revise the MAX-based transaction deduplication and document the rule before using revenue estimates.
