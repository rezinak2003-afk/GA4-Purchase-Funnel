# GA4 Purchase Funnel Analysis — Google Merchandise Store

## Recommendation

**Decision pending data execution.** Run the numbered SQL scripts, validate the session and transaction counts, and identify the largest material funnel gap before choosing the segment to investigate. This repository intentionally contains no invented findings or impact estimates.

## Dashboard / report

-- Looker Studio dashboard: [View the interactive GA4 Purchase Funnel Dashboard](https://datastudio.google.com/reporting/d966689f-64b8-44c6-b8b8-c22563e4696c)
- Two-minute walkthrough: **record and add link after findings are validated**
- One-page recommendation: [`docs/recommendation.pdf`](docs/recommendation.pdf) (draft template; replace after running the analysis)
- Dashboard screenshot: [`docs/screenshots/`](docs/screenshots/) (add real screenshots after publishing)

## Business question

Where do shoppers drop out before purchasing, and which device, first-touch acquisition channel, or landing-page type should the Google Merchandise Store investigate first?

## Data

- **Source:** Google Analytics 4 obfuscated sample e-commerce export for the Google Merchandise Store.
- **BigQuery table:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
- **Date range in scope:** 2020-11-01 through 2021-01-31, inclusive.
- **Documentation:** [Google Analytics sample ecommerce dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset).
- **Data note:** The sample is obfuscated and spans three months that include the holiday season. It is not current live-store data.
- **Licence and usage:** Review the source dataset's current terms before redistributing any exports. Do not commit raw event data; commit only small, derived summary CSVs if useful.

## Definitions

- **Session:** `user_pseudo_id` combined with `ga_session_id`; `ga_session_id` alone is not unique across users.
- **Funnel stages:** Session, `view_item`, `add_to_cart`, `begin_checkout`, and `purchase`.
- **Counting rule:** The headline funnel is flag-based and cumulative: a session counts at a stage only if it reached every preceding stage, ignoring timestamp order. Purchases that skip one or more stages are counted separately in sanity checks.
- **Device:** Session-level `device.category`.
- **Acquisition channel:** `traffic_source.medium` and `traffic_source.source`, explicitly labelled **first-touch user acquisition**. These fields do not represent the current session's source. Missing and known placeholder values are retained in an `Other/unknown` group rather than dropped.
- **Revenue:** Purchase-event revenue after transaction ID diagnostics. For average purchase revenue used in sizing, `purchase_transactions` deduplicates identified transaction IDs only after checking whether duplicate rows carry consistent revenue values.
- **Landing page:** The first `page_view` URL in a session by `event_timestamp`.

## Method

1. Profile event names, event parameters, devices, first-touch media, daily volume and purchase transaction IDs.
2. Flatten only required nested GA4 parameters and create one row per session.
3. Run session sanity checks and record excluded rows.
4. Build overall and segmented funnel tables, then inspect and group landing paths.
5. Compare qualified segments, size the gap at 25%, 50% and 100% closure assumptions, and run a two-proportion significance check.
6. Build a three-page Looker Studio report and write a one-page decision memo based only on produced results.

## Key findings

## Key findings

### 1. Landing-page funnel

- Home landing pages recorded 153,007 sessions, 3,875 checkout sessions, and 1,681 cumulative purchases.
- Home checkout-to-purchase rate was 43.38%.
- Apparel / lifestyle / shop-by pages recorded 122,309 sessions and a 56.49% checkout-to-purchase rate.
- Store page was the highest-rate eligible benchmark observed in the landing-page sizing query, at approximately 69.35%.

### 2. Device comparison

- Mobile: 1,180 purchases from 2,404 checkout sessions (49.08%).
- Desktop: 1,606 purchases from 3,425 checkout sessions (46.89%).
- The two-proportion test returned p = 0.0987. The observed difference was not statistically significant at the 5% level; it should not be presented as proof that mobile performs better.

### 3. Revenue opportunity scenario

- The landing-page sizing query estimated approximately $34,951 at 50% closure of the Home-to-Store-page checkout conversion-rate gap.
- This is a scenario estimate, not a forecast or causal impact claim. It depends on the benchmark being a meaningful comparison and on the purchase-revenue deduplication assumptions.

## Limitations and next steps

- The data is obfuscated, covers one store, and spans only three months including the holiday season.
- `traffic_source` represents first-touch acquisition, not session attribution.
- A segment difference is a pointer for investigation, not proof of a broken experience or of causation.
- The impact estimate assumes some portion of a benchmark gap can be closed; show 25%, 50%, and 100% scenarios rather than presenting one forecast as certain.
- Sample tables in the BigQuery sandbox expire after 60 days by default; retain the SQL and derived summary CSV exports and refresh the tables before sharing a dashboard.

## How to reproduce

1. Follow [`docs/setup.md`](docs/setup.md). Create a BigQuery dataset named `ga4_funnel` in the **US** location.
2. Replace `YOUR_PROJECT` in the SQL scripts with your Google Cloud project ID. Do not enable billing if you are using the sandbox.
3. Run `01_explore_events.sql` and inspect the purchase transaction diagnostics first. If duplicate transaction IDs do not have conflicting revenue values, run `01b_build_purchase_transactions.sql` once, then run `02_build_sessions.sql`, `02b_sanity_checks.sql`, `03_funnel_by_segment.sql`, `03b_overall_funnel.sql`, `04_funnel_long.sql`, `05_breakdowns.sql`, and `06a_inspect_landing_pages.sql`. Inspect the real top landing paths and adjust the CASE patterns in `06b_build_landing_type_summary.sql` before running it. Then run `07_revenue_sizing_by_device.sql`, `07b_revenue_sizing_by_first_touch_medium.sql`, and `07c_revenue_sizing_by_landing_type.sql`. The sizing scripts use the shared `purchase_transactions` table and its `MAX`-based deduplication only if duplicate rows represent repeat copies of the same transaction/revenue value; revise that rule if duplicates are inconsistent.
4. Record actual schema notes and results in [`docs/data_notes.md`](docs/data_notes.md). Inspect real landing paths and tune the illustrative path-type rules before finalising the landing page summary.
5. If comparing mobile and desktop checkout rates, copy actual counts into `notebooks/significance_check.py` and run it as described in [`docs/statistical_check.md`](docs/statistical_check.md).
6. Follow [`dashboard/looker_studio_build_spec.md`](dashboard/looker_studio_build_spec.md), export the small summary tables to `data/processed/`, add genuine screenshots, and update this README with the live links and real findings.
7. Complete `docs/recommendation_memo.md`, replace the draft `docs/recommendation.pdf`, record a two-minute walkthrough, and verify all public links in a private browser window.

## Repository structure

```text
ga4-purchase-funnel/
├── README.md
├── .gitignore
├── requirements.txt
├── sql/                 # numbered BigQuery scripts
├── notebooks/           # significance-check script
├── dashboard/           # Looker Studio build specification
├── docs/                # data notes, decisions, memo, setup and checklists
│   ├── screenshots/     # add real dashboard screenshots
│   └── figures/         # add figures used in the memo
└── data/processed/      # derived summary exports only; never raw events
```
