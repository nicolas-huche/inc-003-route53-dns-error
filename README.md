# INC-003 — HTTPS Certificate Validation Error Investigation

Simulated AWS incident involving HTTPS access failure caused by a Route 53 DNS misconfiguration directing traffic to an incorrect Application Load Balancer.

| Severity | Service | Root Cause                   | MTTD | MTTR |
| -------- | ------- | ---------------------------- | ---- | ---- |
| P2       | Route 53 / ALB / ACM | Route 53 DNS misconfiguration | 3m20 | 4m12 |

> This repository documents a controlled incident simulation created for learning and portfolio purposes.
> The environment was manually provisioned in AWS and the incident was intentionally triggered and investigated using operational tooling and documented evidence.

## TL;DR

Users were unable to access the production application through HTTPS because browser TLS validation failed with a certificate mismatch error.

Investigation confirmed that the ACM certificate was valid and correctly attached to the production Application Load Balancer. Further validation identified that the production Route 53 record was pointing to the wrong Application Load Balancer.

Service was restored by updating the Route 53 record to point back to the correct production ALB and validating recovery through browser testing.

## Architecture

![Topology](architecture/diagrams/topology.svg)

## I want to...

| Goal                                | Go to                                                                      |
| ----------------------------------- | -------------------------------------------------------------------------- |
| Understand the environment          | [`architecture/architecture.md`](architecture/architecture.md)             |
| Reproduce the lab                   | [`architecture/reproduction.md`](architecture/reproduction.md)             |
| Follow the incident timeline        | [`incident/timeline.md`](incident/timeline.md)                             |
| Read the postmortem                 | [`incident/postmortem.md`](incident/postmortem.md)                         |
| See collected evidence              | [`artifacts/manifest.md`](artifacts/manifest.md)                           |
| Run the scripts                     | [`scripts/README.md`](scripts/README.md)                                   |
| Follow the troubleshooting workflow | [`runbooks/https-certificate-error.md`](runbooks/certificate-error.md) |

## Repository Structure

```txt
inc-003-https-certificate-error/
├── architecture/
├── artifacts/
├── incident/
├── runbooks/
├── scripts/
├── README.md
└── LICENSE
```