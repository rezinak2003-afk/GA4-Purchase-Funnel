-- Long-format table for the Looker Studio funnel bar chart.
-- Numeric prefixes preserve the intended stage order in charts.
CREATE OR REPLACE TABLE `YOUR_PROJECT.ga4_funnel.funnel_long` AS
SELECT
  device_category,
  first_touch_medium,
  step_name,
  sessions_at_step
FROM `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
UNPIVOT (
  sessions_at_step FOR step_name IN (
    sessions AS '1 Session',
    view_item AS '2 View item',
    add_to_cart AS '3 Add to cart',
    begin_checkout AS '4 Begin checkout',
    purchase AS '5 Purchase'
  )
);
