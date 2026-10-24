# Decisions log

| Date | Decision | Why / validation needed |
|---|---|---|
| 2026-10-24 | Dataset date suffix range is `20201101`–`20210131`. | Matches the build guide's GA4 sample scope; report the actual min/max `event_date`. |
| 2026-10-24 | Dataset location is US; analysis dataset is `ga4_funnel`. | Required for compatible writes from the public sample. |
| 2026-10-24 | Session key combines `user_pseudo_id` and `ga_session_id`. | `ga_session_id` alone is not globally unique. |
| 2026-10-24 | Headline funnel uses cumulative event flags, ignoring event timestamp order. | Follows the guide's recommended counting rule; also report purchases that skip stages. A time-ordered funnel is a stretch goal only. |
| 2026-10-24 | Channel dimension is labelled first-touch acquisition medium/source. | `traffic_source` does not describe the session's source. Missing and known placeholder labels are retained as `Other/unknown`. |
| 2026-10-24 | Landing-page group patterns will be adjusted after inspecting the actual top paths. | Avoid blindly applying the example regular expressions to uninspected URLs. |
| 2026-10-24 | Landing-page comparisons require a minimum sample threshold; initial guide threshold is 1,000 sessions. | Prevent ranking tiny groups with unstable conversion estimates. |
| 2026-10-24 | Revenue-impact estimate will be shown at 25%, 50%, and 100% closure of the observed gap. | Full gap closure is not guaranteed; a benchmark is an assumption, not a forecast. |
| 2026-10-24 | Do not write findings or resume metrics until queries have been run and rechecked. | Keeps the project reproducible and defensible in interviews. |

Add new decisions as the analysis proceeds. If a decision changes, record why and update the README and query comments.
