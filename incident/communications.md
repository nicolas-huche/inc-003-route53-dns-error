### C-001 — 2026-06-06T19:40:53Z — Initial incident notification

Users are unable to access the production application through HTTPS due to a certificate validation error.

Impact is currently limited to secure access to the production environment. Investigation is in progress.

Next update will be provided once the root cause is identified.

### C-002 — 2026-06-06T19:44:13Z — Root cause identified

The issue was identified as a Route 53 DNS misconfiguration causing the production hostname to resolve to an incorrect Application Load Balancer.

Remediation is being applied. Validation is in progress.

### C-003 — 2026-06-06T19:45:05Z — Incident resolved

HTTPS access has been restored and validated successfully.

The Route 53 record was restored to the correct production Application Load Balancer, and browser validation confirmed that the certificate is now presented correctly.

The incident is now considered fully closed. A postmortem will be completed for documentation purposes.
