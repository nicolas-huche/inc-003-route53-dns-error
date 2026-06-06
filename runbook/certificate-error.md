## When to use

Use this runbook when browsers return NET::ERR_CERT_COMMON_NAME_INVALID while accessing the application endpoint.

Note: This runbook was written for the INC-003 lab environment but follows generic DNS and TLS hostname mismatch troubleshooting patterns.

## How to use

The hypotheses are divided into different sections; however, the instructions must be followed linearly.

Skipping instructions is only permitted if one of the hypotheses before the last one turns out to be the root cause. In that case, it must skip to the validation section.

## Prerequisites

- Access to the AWS Management Console
- Permission to inspect Route 53 resources
- Permission to inspect ACM certificates
- Permission to inspect Application Load Balancers
- Access to the diagnostic scripts referenced by this runbook

## Decision Tree

```txt
NET::ERR_CERT_COMMON_NAME_INVALID
├── ACM Certificate Misconfiguration
├── ALB Listener Misconfiguration
└── Route 53 Misconfiguration
```

## ACM Certificate Misconfiguration

### Investigation

Inspect the certificate presented by the HTTPS endpoint [inspect_certificate.sh](../scripts/REAME.md)

Verify whether the certificate covers the requested hostname.

### Remediation

Attach or issue a certificate that covers the requested hostname.

## ALB Listener Misconfiguration

### Investigation

Inspect the HTTPS listener associated with the production Application Load Balancer with [inspect_listener.sh](../scripts/REAME.md)

Verify whether the certificate attached to the listener covers the production hostname.

### Remediation

Replace the incorrect certificate attachment with the expected production certificate.

## Route 53 Misconfiguration

### Investigation

Inspect the DNS record associated with the production hostname with [inspect_record.sh](../scripts/REAME.md)

Verify whether the DNS record points to the expected production Application Load Balancer.

### Remediation

Restore the DNS record so that the production hostname points to the correct production Application Load Balancer.
Run [fix_record.sh](../scripts/REAME.md)

## Validation

Validate incident resolution using [probe_certificate.sh](../scripts/REAME.md)

## Escalation

Escalate if:

- certificate mismatch persists after corrections
- evidence suggests AWS service degradation
- none of the suggested hypotheses was identified as the root cause

## References

### Architecture

- [architecture.md](../architecture/architecture.md)
- [topology.svg](../architecture/diagrams/topology.svg)
- [traffic-flow.svg](../architecture/diagrams/traffic-flow.svg)

### Troubleshooting Scripts

- [inspect_acm.sh](../scripts/diagnose/inspect_acm.sh)
- [inspect_listener.sh](../scripts/diagnose/inspect_listener.sh)
- [inspect_dns.sh](../scripts/diagnose/inspect_dns.sh)
- [probe_https.sh](../scripts/diagnose/probe_https.sh)
- [restore_dns.sh](../scripts/remediate/restore_dns.sh)