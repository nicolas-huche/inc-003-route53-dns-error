## Manifest Overview

Artifacts generated during the INC-003 HTTPS Certificate Error simulation.

## Artifact Timeline

### Failure Evidence

| Timestamp (UTC) | Artifact | Description |
|---|---|---|
| 2026-06-06T19:40:53Z | [certificate-error.png](./screenshots/2026-06-06T19:40:53Z_certificate-error.png) | Browser shows an HTTPS certificate validation error (NET::ERR_CERT_COMMON_NAME_INVALID) when accessing prod.huche.com.br |

### Diagnostic Evidence

| Timestamp (UTC) | Artifact | Description |
|---|---|---|
| 2026-06-06T19:42:48Z | [inspect_certificate.txt](./cli/2026-06-06T19:42:48Z_inspect_certificate.txt) | ACM certificate inspection confirms a valid issued certificate covering prod.huche.com.br, eliminating certificate issuance and expiration as root causes |
| 2026-06-06T19:43:14Z | [inspect_listener.txt](./cli/2026-06-06T19:43:14Z_inspect_listener.txt) | ALB HTTPS listener inspection confirms the expected ACM certificate is attached to the listener |
| 2026-06-06T19:44:13Z | [inspect_record.txt](./cli/2026-06-06T19:44:13Z_inspect_record.txt) | Route 53 record inspection confirms that prod.huche.com.br points to the wrong Application Load Balancer |

### Remediation Evidence

| Timestamp (UTC) | Artifact | Description |
|---|---|---|
| 2026-06-06T19:44:47Z | [fix_record.txt](./cli/2026-06-06T19:44:47Z_fix_record.txt) | Route 53 record restored to the correct production Application Load Balancer (inc-003-prod-alb) |

### Validation Evidence

| Timestamp (UTC) | Artifact | Description |
|---|---|---|
| 2026-06-06T19:45:05Z | [certificate-secure.png](./screenshots/2026-06-06T19:45:05Z_certificate_secure.png) | Browser confirms successful HTTPS access after DNS correction and certificate validation succeeds |
