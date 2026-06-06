## Overview

This directory contains simple diagnostic utilities used throughout the INC-003 lab environment.

| Script                   | Purpose                                                                                                        |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `inspect_certificate.sh` | Verify whether an issued ACM certificate covers the requested hostname                                         |
| `inspect_listener.sh`    | Verify whether the production ALB listener is configured with a certificate that covers the requested hostname |
| `inspect_record.sh`      | Verify whether the Route 53 record points to the expected production ALB                                       |
| `probe_certificate.sh`   | Validate the certificate currently presented by the endpoint                                                   |
| `inject_failure.sh`      | Intentionally redirects the production Route 53 record to the staging environment                              |

## Dependencies

The scripts require:

* bash
* AWS CLI v2
* OpenSSL

## Usage

### Validation

Validate Certificate:

```bash
./scripts/validation/probe_certificate.sh HOSTNAME
```

### Diagnose

Inspect ACM Certificate:

```bash
./scripts/diagnose/inspect_certificate.sh HOSTNAME
```

Inspect ALB Listener:

```bash
./scripts/diagnose/inspect_listener.sh HOSTNAME
```

Inspect Route 53 Record:

```bash
./scripts/diagnose/inspect_record.sh HOSTNAME
```

### Chaos

Inject the simulated DNS failure:

```bash
./scripts/chaos/inject_failure.sh PRODUCTION_HOSTNAME STAGING_HOSTNAME
```

This updates the production Route 53 record to point to the same endpoint as the staging environment.
