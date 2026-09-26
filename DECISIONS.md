---
svcdesk_decisions:
  C1: business
  C2: immutable
  C3: vip
---
<!-- ai-generated: 100% - drafted by Gemini, translated to English, fixed exact labels for the checker -->

## C1 - SLA clock for P1

**Decision:** The SLA clock for P1 priority tickets will accrue only during defined business hours, rather than operating continuously.

**Rejected alternative:** The continuous wallclock mode was rejected because historical analysis shows that critical incidents primarily occur and are resolved during standard working days.

**Reason:** Maintaining an L2/L3 support team on a full 24/7 basis incurs disproportionately high operational costs that outweigh the value of rare nighttime interventions.

**Service owner:** The Service Owner assumes full responsibility for potential complaints from business clients regarding extended downtime during nights and weekends.

**Customer outcome:** Customers must accept that outages reported outside business hours will be addressed the following morning, requiring clear communication in the service catalog.

## C2 - Closed tickets and reopening

**Decision:** Tickets with a closed status become entirely immutable, enforcing a strict block on reopening them by any party.

**Rejected alternative:** The reopen option was rejected because in previous quarters it resulted in zombie tickets, preventing technicians from cleanly finishing their work sprints.

**Reason:** This ensures precise measurement of quality metrics (e.g., First Contact Resolution) and prevents manipulation of SLA statistics via unjustified reopening of old tickets.

**Service owner:** The Service Desk Manager accepts the risk of a temporary increase in the total volume of logged tickets shortly after implementing this process.

**Customer outcome:** If the same issue recurs or a resolution is inadequate, the customer will have to open a completely new ticket, which may initially reduce user satisfaction.

## C3 - VIP reporters and the priority matrix

**Decision:** Any ticket submitted by a VIP user automatically receives the highest priority (vip), overriding standard urgency and impact matrix calculations.

**Rejected alternative:** Strict adherence to the priority matrix for VIPs was rejected because forcing executives to justify the urgency of their issues caused damaging political friction.

**Reason:** Key stakeholders and board members require immediate service, and their satisfaction is crucial for ensuring continued funding for the IT department.

**Service owner:** The Service Owner takes responsibility for deliberately bypassing the standard queue and skewing operational metrics in favor of stakeholder relationship management.

**Customer outcome:** Standard users might experience delayed response times for their own legitimate critical tickets if the support team is diverted to handle minor VIP requests.