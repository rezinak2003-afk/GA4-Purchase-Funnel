# One-page recommendation memo — complete after running the analysis

**TO:** E-commerce Product / Growth Lead  
**FROM:** [Your name]  
**DATE:** [Date]  
**SUBJECT:** Investigate [qualified funnel segment and step] first

## Bottom line

Investigate **[segment / funnel step]** first. Based on the observed comparison with **[benchmark]**, closing 25%-50% of the measured checkout-completion gap is estimated to represent **$[low]-$[high]** over a comparable three-month period, subject to the assumptions below.

## What we found

1. **Overall funnel:** [actual sessions], [actual purchase sessions], and [actual session-to-purchase conversion].
2. **Segment comparison:** [actual segment rate] versus [actual benchmark rate], a difference of [actual percentage points] at [actual checkout session counts].
3. **Uncertainty and data checks:** [actual p-value], 95% confidence interval [actual interval]; transaction ID and session sanity checks: [actual outcomes].

## Size of the prize

- 25% of gap closed: $[actual estimate]
- 50% of gap closed: $[actual estimate]
- 100% of gap closed: $[actual estimate]

Assumption: benchmark performance can be partially approached, and the estimated average purchase revenue is applicable to incremental orders. This is an opportunity-sizing scenario, not a forecast.

## Recommended action

**Hypothesis:** [specific checkout or page change] will improve [primary metric] for [eligible segment]. Randomise at the user level 50/50. Run for at least one to two full weeks, subject to a suitable sample-size calculation. Primary metric: checkout-to-purchase rate. Guardrails: average order value, refunds, and error rate. Define the minimum detectable lift and success criterion before launch.

## Caveats

- Obfuscated sample for one store, 2020-11-01 through 2021-01-31; the period includes the holiday season.
- `traffic_source` is first-touch user acquisition, not the current session's source.
- The funnel counting rule is cumulative flags and ignores event timestamp order; purchases that skip earlier steps are reported separately.
- A segment gap suggests where to investigate; it does not establish causation or prove that the experience is broken.
- [Any additional validation or data limitations observed]

## Method in one line

[Actual source/table scope], [actual event/session volume], nested GA4 parameters unpacked with `UNNEST`, session-level cumulative funnel, segmented conversion comparisons, gap-closure scenarios, and a two-proportion significance check.

> Remove every bracketed placeholder after the queries run. Do not publish this memo as a final finding until all values are verified from your results.
