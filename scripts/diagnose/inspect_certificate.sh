#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

HOSTNAME="${1:-}"

if [[ -z "${HOSTNAME}" || -n "${2:-}" ]]; then
    log_error "Usage: $0 <production-domain>"
    exit 1
fi

log_info "Inspecting certificate for hostname: ${HOSTNAME}"

CERTIFICATE_ARN=$(
    aws acm list-certificates \
        --certificate-statuses ISSUED \
        --query "CertificateSummaryList[?DomainName=='${HOSTNAME}' || contains(SubjectAlternativeNameSummaries, '${HOSTNAME}')].CertificateArn | [0]" \
        --output text
)

if [[ -z "${CERTIFICATE_ARN}" || "${CERTIFICATE_ARN}" == "None" ]]; then
    log_error "ACM Certificate Misconfiguration confirmed: no issued ACM certificate covers ${HOSTNAME}"
    exit 1
fi

aws acm describe-certificate \
    --certificate-arn "${CERTIFICATE_ARN}" \
    --query 'Certificate.{CertificateArn:CertificateArn,DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames,Status:Status}' \
    --output table

log_info "ACM Certificate Misconfiguration discarded: an issued ACM certificate covers ${HOSTNAME}"
