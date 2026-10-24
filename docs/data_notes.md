# Data notes — fill from actual BigQuery results

Do not fill these fields from examples or assumptions. Paste/run results from `sql/01_explore_events.sql` and `sql/02b_sanity_checks.sql`.

## Source and scope

- Source table: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
- Requested date suffixes: `20201101` to `20210131`
- Actual minimum/maximum `event_date`: **[record query result]**
- Data caveat: obfuscated sample, one store, three-month period including holiday season.

## Event profile

- Total events: **[result]**
- Distinct `user_pseudo_id`: **[result]**
- Confirmed event names and counts: **[paste output]**
- Missing expected event names, if any: **[result]**

## Nested parameters and schema

- `ga_session_id` parameter exists and uses `value.int_value`: **[yes/no and evidence]**
- `page_location` parameter exists and uses `value.string_value`: **[yes/no and evidence]**
- Device categories observed: **[result]**
- First-touch media/source examples: **[result]**
- Placeholders such as `(not set)`, `(data deleted)` or `<Other>` observed: **[describe; do not silently delete]**
- `ecommerce.purchase_revenue_in_usd` exists/population on purchase events: **[result]**
- `ecommerce.transaction_id` exists/population on purchase events: **[result]**
- Duplicate nonempty transaction IDs: **[result]**
- Duplicate IDs with more than one distinct revenue value: **[result; stop and investigate if nonzero]**
- Identified transactions and average revenue per identified transaction after deduplication: **[result]**

## Session sanity checks

- Session rows: **[result]**
- Distinct session keys: **[result; must equal session rows]**
- Users represented: **[result]**
- Raw events with null `ga_session_id`: **[result]**
- Raw events with null `user_pseudo_id`: **[result]**
- Sessions with purchase but no add-to-cart: **[result]**
- Sessions with purchase but no view-item: **[result]**
- Sessions with begin-checkout but no add-to-cart: **[result]**

## Funnel findings

- Overall stages and conversion rates: **[paste query output]**
- Device breakdown: **[paste query output]**
- First-touch medium breakdown: **[paste query output]**
- Top 50 landing paths inspected: **[yes/no; notes]**
- Final landing-type definitions: **[document actual URL patterns]**
- Minimum session threshold applied to segment/page groups: **[record threshold; default guide recommendation is 1,000 for landing-page groups]**
- Biggest qualified gap and chosen benchmark: **[result]**
- 25% / 50% / 100% gap-closure revenue scenarios: **[result]**
- Statistical test, p-value and 95% confidence interval: **[result]**

## Query quality notes

- Bytes processed estimates checked before source queries: **[yes/no]**
- Any sandbox restrictions or alternative save-results workflow: **[describe]**
- Any unexpected schema or data behaviour and resolution: **[describe]**
