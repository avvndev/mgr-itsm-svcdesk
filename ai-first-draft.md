---
lab3_first_draft:
  source: ai
  tool: gemini
  ladder:
    - 0.01
    - 0.02
    - 0.05
    - 0.1
    - 0.15
    - 0.2
    - 0.25
    - 0.3
    - 0.35
    - 0.4
    - 0.45
    - 0.5
    - 0.6
    - 0.7
    - 0.8
    - 0.9
    - 1.0
    - 1.5
    - 2.0
    - 2.5
    - 3.0
  verdict: pending
  evidence:
    p99_seconds: 0.0
    bucket: [0.0, 0.0]
    relative_width: 0.0
lab3_flawed_ladder:
  verdict: refuted
  evidence:
    p99_seconds: 0.0
    bucket: [0.0, 0.0]
    relative_width: 0.0
---
<!-- ai-generated: 100% - assistant proposed first draft ladder and alert rule -->

## Prompt

Proszę o podanie propozycji granic przedziałów histogramu (bucket boundaries w sekundach) dla metryki czasów odpowiedzi HTTP końcówki GET /kb/search oraz reguły alertowej Prometheus sprawdzającej opóźnienia P99.

## Answer

Dla punktu końcowego GET /kb/search proponuję następujące granice przedziałów histogramu w sekundach:
[0.01, 0.02, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.5, 2.0, 2.5, 3.0]

Przykładowa reguła alertowa Prometheus:

> ```yaml
> groups:
>   - name: kb_search_alerts
>     rules:
>       - alert: KBSearchHighLatency
>         expr: histogram_quantile(0.99, sum(rate(http_server_request_duration_seconds_bucket{http_route="/kb/search"}[5m])) by (le)) > 0.5
>         for: 2m
>         labels:
>           severity: P1
>           service: svcdesk
>           slo: latency
>         annotations:
>           summary: "GET /kb/search P99 latency exceeds 500ms"
> ```
