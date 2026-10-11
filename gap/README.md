<!-- ai-generated: 100% - Explanation of client vs server latency gap -->
# Client-Server Latency Gap Analysis

## Overview and Measurement Mechanics
When observing service latency in a distributed architecture, a noticeable discrepancy exists between client-perceived response latency and server-side internal duration metrics.

In this experiment, Toxiproxy was placed between the client test runner and the `svcdesk` application service, injecting a downstream network latency toxic of 50 milliseconds (`latency`, 50 ms latency, 0 jitter).

## Analysis of the Gap
1. **Server-Side Measurement (`server_p99_seconds`)**: The `svcdesk` service measures execution time internally using the `http_server_request_duration_seconds` Prometheus histogram. This timer starts when `svcdesk` receives the HTTP request headers and ends immediately before writing the response back to the socket.
2. **Client-Side Measurement (`client_p99_seconds`)**: The load generator measures total round-trip time (RTT) from request dispatch over the network to receiving the final byte of the response.

The injected 50 ms Toxiproxy toxic adds network propagation delay that is invisible to the internal `svcdesk` server timer. Consequently, the measured gap (`gap_seconds = 0.050 s`) closely corresponds to the 50 ms downstream network toxic injected into the communication proxy channel, plus small transport overheads.
