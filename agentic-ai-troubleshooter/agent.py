
import json, sys, statistics
from datetime import datetime

"""
Simple agent that reads JSONL logs and suggests next diagnostic steps.
Usage: python agent.py dataset/simulated_logs.jsonl
"""

SEVERITY = {
    'HTTP500': 3,
    'DependencyTimeout': 4,
    'HighCPU': 2,
    'FailedLogin': 3
}

SUGGESTIONS = [
    (lambda c: c.get('HTTP500', 0) > 20, 'Spike in HTTP 500s: check recent deployments, swap slots, collect App Insights exceptions, verify connection strings.'),
    (lambda c: c.get('DependencyTimeout', 0) > 5, 'Dependency timeouts detected: test outbound rules/VNet, increase retry/backoff, review TTLs and health checks.'),
    (lambda c: c.get('HighCPU', 0) > 10, 'High CPU trend: profile hot paths, scale out temporarily, review thread pools and caching.'),
    (lambda c: c.get('FailedLogin', 0) > 5, 'Authentication failures: tune alert thresholds, check RBAC, enable lockout policy, correlate with watchlist.')
]

def load(path):
    with open(path, 'r', encoding='utf-8') as f:
        return [json.loads(line) for line in f if line.strip()]

def summarize(events):
    counts = {}
    for e in events:
        t = e.get('type')
        counts[t] = counts.get(t, 0) + 1
    return counts

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python agent.py <jsonl-path>')
        sys.exit(1)
    events = load(sys.argv[1])
    counts = summarize(events)
    suggestions = [msg for cond, msg in SUGGESTIONS if cond(counts)]
    output = {
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'counts': counts,
        'suggestions': suggestions or ['No anomalies detected. Continue standard triage.']
    }
    print(json.dumps(output, indent=2))
