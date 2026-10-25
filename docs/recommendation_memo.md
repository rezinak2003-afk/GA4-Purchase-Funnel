# Recommendation Memo: GA4 Purchase Funnel Analysis

**Dataset:** Google Merchandise Store GA4 sample  
**Analysis period:** November 1, 2020 – January 31, 2021  
**Prepared by:** Data Analytics Portfolio Project

## Executive Recommendation

Prioritize an investigation of the Home landing-page experience before making product or checkout changes. The Home landing-page group has substantial session volume and a lower checkout-to-purchase rate than the Store page benchmark in this analysis. This difference identifies an opportunity to investigate; it does not establish that the Home page causes purchase drop-off.

## Key Findings

### 1. Landing-page funnel

The Home landing-page group recorded 153,007 sessions, 3,875 checkout sessions, and 1,681 cumulative purchases. Its checkout-to-purchase rate was 43.38%.

The Apparel / lifestyle / shop-by group recorded 122,309 sessions and a checkout-to-purchase rate of 56.49%. The Store page group had the highest eligible benchmark rate observed in the analysis, approximately 69.35%.

These comparisons are based on session-level event flags, not strict timestamp-ordered journeys. Landing-page categories are rule-based groupings and should be reviewed against the underlying paths.

### 2. Device comparison

Mobile recorded 1,180 purchases from 2,404 checkout sessions, a rate of 49.08%. Desktop recorded 1,606 purchases from 3,425 checkout sessions, a rate of 46.89%.

The two-proportion test returned p = 0.0987. The difference was not statistically significant at the 5% level. The observed mobile advantage should not be treated as proof of better performance or as a causal effect.

### 3. Revenue opportunity scenario

The Home-to-Store-page rate-gap analysis estimated approximately **$34,951** under a 50% gap-closure scenario. This is an illustrative scenario, not a forecast or guaranteed financial impact. It relies on the chosen benchmark, average identified transaction revenue, and transaction-deduplication assumptions.

## Recommended Next Steps

1. Inspect the highest-volume Home landing paths and compare the actual user journeys with the Store page paths.
2. Validate the landing-page classification rules and verify purchase transaction deduplication before presenting revenue scenarios externally.
3. Investigate potential usability issues using additional evidence, such as page behaviour, device experience, and checkout diagnostics.
4. If a plausible issue is identified, propose a measurable experiment and evaluate the outcome before claiming business impact.

## Limitations

The data is an obfuscated sample from one store covering three months that include the holiday season. It is not current live-store data. First-touch acquisition fields do not represent session-level attribution. Funnel flags do not enforce event timestamp order, and segment comparisons do not prove causality.

## Decision

**Proceed with investigation, not an immediate redesign.** Validate the Home landing-page journey and supporting evidence before prioritising a change or communicating revenue impact.
