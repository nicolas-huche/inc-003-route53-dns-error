# Summary

On 2026-06-06, users were unable to access the production application through HTTPS due to a certificate validation error. Investigation determined that the production hostname resolved to an incorrect Application Load Balancer because of a Route 53 DNS misconfiguration.

Service was restored by updating the Route 53 record to point back to the correct production Application Load Balancer.

## Impact

Impact was limited to HTTPS access to the production environment.

Users attempting to access the application received certificate validation errors because the hostname resolved to an endpoint presenting a certificate for a different domain.

The application infrastructure remained operational, but TLS validation failed before users could successfully establish a secure connection.

## Detection

The incident was initially detected when browser access to the production application displayed an HTTPS certificate validation error (NET::ERR_CERT_COMMON_NAME_INVALID).

## Response

The investigation followed sequential validation of the HTTPS request path.

The following components were validated in order:

1. ACM certificate status
2. ALB HTTPS listener configuration
3. Route 53 DNS record

Findings:

1. The ACM certificate was valid and issued for the production hostname.
2. The expected ACM certificate was attached to the production ALB HTTPS listener.
3. The Route 53 record pointed to an incorrect Application Load Balancer.

This process eliminated certificate and listener configuration issues and isolated the failure to the DNS configuration.

## Root Cause Analysis

### Trigger

Route 53 record inspection identified that the production hostname was configured to resolve to the wrong Application Load Balancer.

As a result, user traffic was directed to an endpoint presenting a certificate belonging to a different hostname.

### Root Cause

The root cause was a Route 53 DNS misconfiguration.

The production DNS record pointed to an incorrect Application Load Balancer rather than the intended production ALB. Because the incorrect endpoint presented a certificate for another domain, browser TLS validation failed and users received certificate mismatch errors.

### Five Whys

1. Why were users unable to access the application through HTTPS?
   Because browser TLS validation failed.

2. Why did TLS validation fail?
   Because the certificate presented by the endpoint did not match the requested hostname.

3. Why was the incorrect certificate presented?
   Because the request reached the wrong Application Load Balancer.

4. Why did traffic reach the wrong Application Load Balancer?
   Because the Route 53 record pointed to the incorrect endpoint.

5. Why was the issue not detected before impact occurred?
   Because no validation existed to verify that the production DNS record continued to resolve to the expected Application Load Balancer after DNS changes.

### Contributing Factors

- DNS changes could be applied without validation of the resulting endpoint mapping.
- No automated verification existed to confirm that the production hostname resolved to the intended Application Load Balancer.
- The observed symptom appeared to be a certificate problem, while the actual root cause existed in the DNS layer.
- Browser error messages focused on TLS validation failures, requiring investigation across multiple infrastructure layers.

## Mitigation

The incident was resolved by restoring the Route 53 record to the correct production Application Load Balancer.

After the DNS correction was applied, browser validation confirmed that the expected certificate was presented and HTTPS access functioned normally.

## Final Metrics

| Metric | Value |
|---|---|
| Detection to root cause identification | 3 minutes 20 seconds |
| Detection to recovery | 4 minutes 12 seconds |
| Total incident duration | 4 minutes 12 seconds |

## References

### Timeline
- [incident/timeline.md](../incident/timeline.md)

### Communications
- [incident/communications.md](../incident/communications.md)

### Artifact manifest
- [artifacts/manifest.md](../artifacts/manifest.md)

### Key evidence
- [artifacts/screenshots/certificate-error.png](../artifacts/screenshots/2026-06-06T19:40:53Z_certificate-error.png)
- [artifacts/cli/inspect_certificate.txt](../artifacts/cli/2026-06-06T19:42:48Z_inspect_certificate.txt)
- [artifacts/cli/inspect_listener.txt](../artifacts/cli/2026-06-06T19:43:14Z_inspect_listener.txt)
- [artifacts/cli/inspect_record.txt](../artifacts/cli/2026-06-06T19:44:13Z_inspect_record.txt)
- [artifacts/cli/fix_record.txt](../artifacts/cli/2026-06-06T19:44:47Z_fix_record.txt)
- [artifacts/screenshots/certificate_secure.png](../artifacts/screenshots/2026-06-06T19:45:05Z_certificate_secure.png)