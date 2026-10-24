"""Two-proportion check for actual mobile vs desktop checkout completion counts.

Copy counts from your BigQuery output; do not use illustrative/example numbers.
Example (replace all values with observed counts):
  python notebooks/significance_check.py --group-a mobile --success-a 120 --trials-a 500 \
      --group-b desktop --success-b 140 --trials-b 500

`success` means cumulative purchase sessions. `trials` means cumulative begin-checkout sessions.
The test checks a difference in proportions; it does not prove a causal device effect.
"""

from __future__ import annotations

import argparse
import sys

from statsmodels.stats.proportion import confint_proportions_2indep, proportions_ztest


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--group-a", default="mobile", help="Name of the first segment")
    parser.add_argument("--success-a", type=int, required=True, help="Purchase sessions for group A")
    parser.add_argument("--trials-a", type=int, required=True, help="Begin-checkout sessions for group A")
    parser.add_argument("--group-b", default="desktop", help="Name of the benchmark segment")
    parser.add_argument("--success-b", type=int, required=True, help="Purchase sessions for group B")
    parser.add_argument("--trials-b", type=int, required=True, help="Begin-checkout sessions for group B")
    return parser.parse_args()


def validate(success: int, trials: int, label: str) -> None:
    if trials <= 0:
        raise ValueError(f"{label}: trials must be greater than zero")
    if success < 0 or success > trials:
        raise ValueError(f"{label}: successes must be between 0 and trials")


def main() -> int:
    args = parse_args()
    try:
        validate(args.success_a, args.trials_a, args.group_a)
        validate(args.success_b, args.trials_b, args.group_b)
    except ValueError as exc:
        print(f"Input error: {exc}", file=sys.stderr)
        return 2

    counts = [args.success_a, args.success_b]
    nobs = [args.trials_a, args.trials_b]
    z_stat, p_value = proportions_ztest(count=counts, nobs=nobs, alternative="two-sided")
    ci_low, ci_high = confint_proportions_2indep(
        args.success_a,
        args.trials_a,
        args.success_b,
        args.trials_b,
    )
    rate_a = args.success_a / args.trials_a
    rate_b = args.success_b / args.trials_b

    print("Two-proportion z-test (two-sided)")
    print(f"{args.group_a}: {args.success_a}/{args.trials_a} = {rate_a:.2%}")
    print(f"{args.group_b}: {args.success_b}/{args.trials_b} = {rate_b:.2%}")
    print(f"Difference ({args.group_a} - {args.group_b}): {rate_a-rate_b:.2%}")
    print(f"z statistic: {z_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"95% CI for difference: {ci_low:.3f} to {ci_high:.3f}")
    print("Interpretation: describe uncertainty; a segment difference is not proof of causation.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
