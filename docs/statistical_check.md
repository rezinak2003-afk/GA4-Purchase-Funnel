# Statistical check

Use this after selecting a candidate device gap and copying the observed session counts from the BigQuery results.

For the primary guide example:

- successes = cumulative purchase sessions for mobile and desktop
- trials = cumulative begin-checkout sessions for mobile and desktop
- test = two-sided two-proportion z-test
- report = both observed rates, their difference, p-value, and 95% confidence interval for the difference

Run from the repository root after installing requirements:

```bash
python -m venv .venv
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# macOS/Linux:
source .venv/bin/activate
pip install -r requirements.txt
python notebooks/significance_check.py --group-a mobile --success-a ACTUAL_MOBILE_PURCHASES --trials-a ACTUAL_MOBILE_CHECKOUTS --group-b desktop --success-b ACTUAL_DESKTOP_PURCHASES --trials-b ACTUAL_DESKTOP_CHECKOUTS
```

Replace every `ACTUAL_...` token with integer results from your own query before running. Do not use invented counts. If a rate difference is statistically compatible with zero, avoid overstating a segment gap. A statistically significant difference is still not evidence that device choice caused the difference.
