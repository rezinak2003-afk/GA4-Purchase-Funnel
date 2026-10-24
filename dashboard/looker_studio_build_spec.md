# Looker Studio dashboard build specification

Build a report at <https://lookerstudio.google.com/> after the BigQuery tables exist. The live report and screenshots must be added after a real build; this file is the reproducible specification, not a claim that a dashboard is already hosted.

## Data sources

1. BigQuery table `YOUR_PROJECT.ga4_funnel.funnel_long`
2. BigQuery table `YOUR_PROJECT.ga4_funnel.funnel_by_segment`
3. BigQuery table `YOUR_PROJECT.ga4_funnel.landing_type_summary` (created after manually reviewing and adjusting the landing-path classification rules)

Use the BigQuery connector and choose the US-region dataset. Test access from a private browser window before including the public link in the README.

## Page 1 — Funnel overview

- Scorecards: sessions, purchase sessions, overall conversion, purchase revenue.
- Horizontal bar chart: `step_name` dimension, `SUM(sessions_at_step)` metric, sorted by `step_name` ascending so prefixes preserve funnel order.
- Conversion table: session-to-view, view-to-cart, cart-to-checkout, checkout-to-purchase, overall conversion.
- Use the cumulative flag-based counting rule from the README consistently.

## Page 2 — Where the leak is

- Conversion by device category.
- Conversion by first-touch acquisition medium; title it as first-touch acquisition, not session attribution.
- Landing-type conversion using `landing_type_summary`, whose categories must be based on inspected URLs and the final cumulative funnel definition.
- Suppress or group low-volume landing groups; use at least 1,000 sessions as the initial threshold unless a documented reason supports another threshold.
- Add drop-down controls for device and first-touch medium so viewers can filter applicable charts.

## Page 3 — Recommendation

- State the highest-priority qualified gap, benchmark and measured rates.
- Show the 25%, 50% and 100% gap-closure opportunity range based on observed average purchase revenue.
- Include the significance result and its uncertainty.
- State a test hypothesis, primary metric, guardrails, randomisation unit, expected duration (at least one to two full weeks), and how success will be judged.

## Titles and footer

Use finding-led chart titles after real results are known; do not hard-code example findings. Example pattern: `Investigate [segment]: checkout completion is [X] percentage points below [benchmark]`.

Add this footer to every page:

`Source: Google Merchandise Store GA4 obfuscated sample | Period: 2020-11-01 to 2021-01-31 | traffic_source is first-touch user acquisition, not session attribution | Observational analysis; differences are not proof of causation.`

## Share and archive

- Use the guide's sharing setting `Anyone with the link can view` only if appropriate for your account and the data source permits it.
- Export/save genuine dashboard screenshots to `docs/screenshots/`.
- Export only small derived summary tables to `data/processed/` as backup.
- Note that sandbox-created tables can expire; refresh the SQL/tables and test the dashboard before sharing.
