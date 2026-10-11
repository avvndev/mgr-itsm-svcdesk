---
ai-generated: 100% - SLO specification and defense for svcdesk
lab3_slo:
  service: svcdesk
  route: /kb/search
  window: 28d
  slis:
    availability:
      objective: 0.99
      error_budget:
        fraction: 0.01
        minutes: 403.2
      good: sum(rate(http_server_request_duration_seconds_count{http_route="/kb/search", http_response_status_code=~"2.."}[5m]))
      valid: sum(rate(http_server_request_duration_seconds_count{http_route="/kb/search"}[5m]))
    latency:
      threshold_seconds: 0.2
      objective: 0.99
      error_budget:
        fraction: 0.01
        minutes: 403.2
      good: sum(rate(http_server_request_duration_seconds_bucket{http_route="/kb/search", le="0.2"}[5m]))
      valid: sum(rate(http_server_request_duration_seconds_count{http_route="/kb/search"}[5m]))
  alerts:
    - alert: KBSearchLatencyBurnRateHigh
      name: KBSearchLatencyBurnRateHigh
      sli: latency
      long_window: 1h
      short_window: 5m
      burn_rate: 14.4
      severity: P1
    - alert: KBSearchLatencyBurnRateMedium
      name: KBSearchLatencyBurnRateMedium
      sli: latency
      long_window: 6h
      short_window: 30m
      burn_rate: 6.0
      severity: P2
---
<!-- ai-generated: 100% - SLO specification and defense for svcdesk -->

# Service Level Objectives (SLO) for svcdesk

## Service Overview
The `svcdesk` service proxies knowledge base search requests to the upstream `kb-index` service via `GET /kb/search`.

## SLI & SLO Definitions

### 1. Availability SLI
- **Objective**: 99.0% (0.99) valid requests answer with 2xx HTTP status codes.
- **Window**: 28 days (40,320 minutes).
- **Error Budget**: 1.0% fraction, corresponding to 403.2 minutes over 28 days ($0.01 \times 40320 = 403.2$).
- **Defense & Upstream Dependency**: Upstream `kb-index` exhibits intermittent 503 failures that propagate through `svcdesk` as 502 responses. Setting the availability objective to 99.0% accounts for realistic upstream failure rates while keeping service degradation within acceptable business boundaries. An objective of 99.9% would be unrealistic given the unmitigated failure rate of `kb-index`, quickly depleting the budget through external instability.

### 2. Latency SLI
- **Objective**: 99.0% (0.99) valid requests respond within 0.20 seconds (200 ms).
- **Threshold**: 0.20 s (which is an exact boundary in our custom histogram bucket ladder).
- **Window**: 28 days (40,320 minutes).
- **Error Budget**: 1.0% fraction, corresponding to 403.2 minutes over 28 days ($0.01 \times 40320 = 403.2$).
- **Defense & Upstream Latency Profile**: In our benchmark measurement, the upstream `kb-index` reported a P99 of $q_{kb} = 0.1266\text{ s}$ and `svcdesk` measured $q = 0.129\text{ s}$. The latency threshold of 0.20 s provides a practical ~55% headroom above the normal 99th percentile, tolerating minor network jitter and CPU scheduling delays while detecting upstream "slow mode" episodes. Selecting 0.20 s as an exact bucket boundary ensures that the SLI is strictly evaluated via counting actual requests rather than relying on histogram interpolation.

## Multiwindow, Multi-Burn-Rate Alerting Strategy

| alert | SLI | burn rate | long window | short window | severity | target |
|---|---|---|---|---|---|---|
| `KBSearchLatencyBurnRateHigh` | latency | 14.4 | 1h | 5m | P1 | Pager |
| `KBSearchLatencyBurnRateMedium` | latency | 6.0 | 6h | 30m | P2 | Chat |

### 1. P1 High Burn Rate Alert (`KBSearchLatencyBurnRateHigh`)
- **Condition**: 1-hour window error rate $> 14.4 \times (1 - 0.99) = 0.144$ AND 5-minute window error rate $> 0.144$.
- **Budget Impact**: Consumes 2% of the 28-day error budget in 1 hour (would exhaust 100% in 46.7 hours).
- **Routing**: **P1 (Pager)**. Immediate escalation to on-call engineer is justified because rapid degradation threatens complete budget exhaustion in less than two days.

### 2. P2 Medium Burn Rate Alert (`KBSearchLatencyBurnRateMedium`)
- **Condition**: 6-hour window error rate $> 6.0 \times (1 - 0.99) = 0.060$ AND 30-minute window error rate $> 0.060$.
- **Budget Impact**: Consumes 5% of the 28-day error budget in 6 hours (would exhaust 100% in 4.7 days).
- **Routing**: **P2 (Chat / Ticketing)**. Routed to the team's operations chat during business hours. A sustained burn at this rate warrants investigation before the next working day, but does not justify waking an engineer in the middle of the night.

## Custom Bucket Ladder Defense
- **Measured P99 ($q$):** 0.129 s.
- **Ladder Boundaries (21 boundaries):**
  `[0.005, 0.01, 0.025, 0.05, 0.075, 0.10, 0.11, 0.12, 0.13, 0.14, 0.15, 0.175, 0.20, 0.25, 0.30, 0.40, 0.50, 0.75, 1.0, 2.0, 5.0]`
- **Resolution of $q$:** The measured P99 falls in $(0.12, 0.13]$, with width $0.01\text{ s}$. The relative width is $\frac{0.01}{0.129} \approx 7.75\%$, which is well within the required $20\%$ bound (M-11).
- **Resolved Band:** Boundaries $0.10, 0.11, 0.12, 0.13, 0.14, 0.15$ resolve a $\pm 15\%$ band around $q$ with $10\text{ ms}$ granularity.
- **Threshold Boundary:** Boundary $0.20\text{ s}$ matches the latency SLI threshold exactly (M-13).
- **Remaining Boundaries:** Boundaries below $0.10\text{ s}$ capture median and low-latency fast-path queries, while boundaries from $0.25\text{ s}$ to $5.0\text{ s}$ capture tail latency and slow-mode spikes up to timeouts.
