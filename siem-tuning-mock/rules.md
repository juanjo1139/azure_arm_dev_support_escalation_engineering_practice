
# Sentinel-style Analytic Rule Examples

## Rule: Excessive 5xx Responses
**Logic:** If `HTTP500` events > 50 in 5 minutes, raise High severity.
**Tuning:**
- Suppress duplicates per endpoint.
- Require at least 3 distinct client IPs.

## Rule: Brute Force Login from Watchlist IP
**Logic:** >= 5 `FailedLogin` from same IP within 10 minutes, and IP in watchlist.
**Tuning:**
- Add threshold; exclude service accounts; correlate with GeoIP.

## Dashboards
- Requests, 5xx trend, dependency failures, noisy rules top-N.
