# Setup and run order

## Required accounts/tools

- Google account for BigQuery sandbox and Looker Studio.
- Git and a GitHub account; create a separate repository named `ga4-purchase-funnel`.
- Python 3.10+ only for the optional statistical check.

## BigQuery setup

1. Open <https://console.cloud.google.com/bigquery> and sign in.
2. Create a Google Cloud project, for example `ga4-funnel-portfolio`. Use the sandbox without enabling billing.
3. In BigQuery, create a dataset named `ga4_funnel` in region **US**. The public sample is in the US; a different region can prevent writes across regions.
4. In Explorer, add/star the project `bigquery-public-data`, then open `ga4_obfuscated_sample_ecommerce` and inspect the schema of an `events_*` table.
5. Replace `YOUR_PROJECT` in scripts with your exact project ID. Keep the dataset name `ga4_funnel` unless you update every reference consistently.
6. Before running each query, inspect BigQuery's bytes-processed estimate. Every raw-table query must filter `_TABLE_SUFFIX`; these scripts do so. Avoid `SELECT *` on the source events table.

The supplied guide describes a sandbox quota of roughly 1 TB of queries per month and 10 GB of storage, with created tables expiring after 60 days by default. Verify the limits shown in your own console; provider limits can change.

## Run order

1. Run query sections A-E in `sql/01_explore_events.sql` and save observations in `docs/data_notes.md`.
2. Confirm `ga_session_id`, `page_location`, and purchase transaction/revenue fields exist in the schema before running sections F-G in `01_explore_events.sql`. Inspect the duplicate transaction query; if a duplicate transaction ID has inconsistent revenue values, stop and define a correct rule before proceeding.
3. `sql/01b_build_purchase_transactions.sql`: create the shared purchase transaction table after the duplicate check, then confirm no transaction has inconsistent revenue values.
4. `sql/02_build_sessions.sql`: creates the session table. If sandbox `CREATE TABLE` is rejected, use BigQuery's supported save-results/create-view route and document the change.
5. `sql/02b_sanity_checks.sql`: record all counts and resolve unexpected key mismatches before proceeding.
6. `sql/03_funnel_by_segment.sql` and `sql/03b_overall_funnel.sql`.
7. `sql/04_funnel_long.sql`.
8. `sql/05_breakdowns.sql`.
9. Run `sql/06a_inspect_landing_pages.sql` first. Review the real top paths, edit the CASE patterns in `sql/06b_build_landing_type_summary.sql`, then run `06b` to create `landing_type_summary`.
10. `sql/07_revenue_sizing_by_device.sql`, `sql/07b_revenue_sizing_by_first_touch_medium.sql`, and `sql/07c_revenue_sizing_by_landing_type.sql`: run only after transaction-ID diagnostics and funnel checks are acceptable. Inspect duplicate transaction rows first; the sizing scripts use `MAX` per transaction ID only when those duplicates represent repeat copies of the same transaction/revenue value.
11. Run the statistical check using counts copied from your actual output.
12. Build Looker Studio and write the memo from the produced numbers.

## Repository safety

- Do not commit raw data or private credentials.
- Add only small, derived result CSVs to `data/processed/`.
- Before every push, review `git status` and inspect all staged files.
