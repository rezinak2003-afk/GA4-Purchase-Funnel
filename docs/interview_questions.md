# Interview questions to rehearse

## How did you define a session?
A session is keyed by `user_pseudo_id` plus `ga_session_id`; the session ID alone is not globally unique.

## Why does `traffic_source` need a caveat?
In this export it describes first-touch user acquisition, not the source of each particular session. Therefore, label the breakdown first-touch acquisition.

## How did you handle sessions that skip funnel steps?
The headline funnel counts a session at a stage only if all prior flags are present, without enforcing event timestamp order. We count purchases that skip earlier steps separately and state the limitation.

## How confident are you in the revenue estimate?
It is a 25%/50%/100% gap-closure scenario using observed average purchase revenue, not a forecast. We check transaction IDs, report a confidence interval/p-value for the key rate difference, and state the benchmark assumption.

## What would you do with more data?
Build a time-ordered funnel, analyse product-level steps, use a longer period outside the holiday season, and run a properly powered A/B test.

## What are the dataset's limits?
It is an obfuscated sample for one store over three months, includes the holiday period, has no cost or margin data, and cannot establish causation from observational differences.
