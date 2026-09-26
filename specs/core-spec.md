<!-- ai-generated: 100% - Gemini CLI spec generation -->
# svcdesk - Core Specification

## 1. Overview & Architecture
The `svcdesk` service is an HTTP-based IT service management ticketing system designed to run as a containerized service listening on port 8080. It provides a robust JSON REST API for ticket management, priority calculation, SLA tracking, and state transitions, ensuring persistence across container restarts.

## 2. Requirement Conflicts and Arbitrary Path Selections

### C1: SLA Clock for P1 Tickets
- **Conflict:** Whether P1 tickets use wall-clock time (`wallclock`) or business-hours time (`business`).
- **Chosen Path:** `business`
- **Architecture & Behavior:** All priorities, including P1, utilize the business-hours clock (Monday to Friday, 08:00 to 16:00 Europe/Warsaw, DST-aware). SLA targets for P1 tickets account for business windows and pause outside business hours.

### C3: VIP Reporter Priority Rules
- **Conflict:** Whether VIP status affects ticket priority (`vip`) or whether priority is strictly determined by the impact/urgency matrix (`matrix`).
- **Chosen Path:** `vip`
- **Architecture & Behavior:** When a ticket is created by a VIP reporter (`reporter.vip = true`), any resulting priority of P3 or P4 is automatically elevated to P2. P1 and P2 priorities remain unaffected by VIP status.

### C2: Ticket Closing and Reopening
- **Conflict:** Whether closed tickets can be reopened within 7 days (`reopen`) or if closed tickets are fully immutable (`immutable`).
- **Chosen Path:** `immutable`
- **Architecture & Behavior:** Once a ticket enters the `closed` state, it is completely immutable. Reopening is permitted only from the `resolved` state within the 7-day window. Reopening a closed ticket is prohibited and returns a `409 Conflict` response.

## 3. Core API Endpoints and Validation
- `GET /health`: Service health status.
- `POST /tickets`: Ticket creation with server-computed priority and SLA due dates.
- `GET /tickets`: Ticket listing with optional `state` and `priority` filters.
- `GET /tickets/{id}`: Detailed ticket view.
- `GET /tickets/{id}/sla`: SLA tracking, breach status, and pause status.
- State transition endpoints (`/ack`, `/start`, `/resolve`, `/close`, `/reopen`) following strict lifecycle rules.
- Test clock support via `X-Test-Clock` when `SVCDESK_TEST_CLOCK` is enabled.
