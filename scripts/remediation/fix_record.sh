#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

HOSTNAME="${1:-}"

if [[ -z "${HOSTNAME}" || -n "${2:-}" ]]; then
    log_error "Usage: $0 <production-domain>"
    exit 1
fi

RECORD_NAME="${HOSTNAME%.}."
ZONE_NAME="$(printf "%s" "${RECORD_NAME}" | cut -d'.' -f2-)"
SUBDOMAIN="$(printf "%s" "${HOSTNAME}" | cut -d'.' -f1)"

log_info "Restoring Route 53 record for ${RECORD_NAME}"

HOSTED_ZONE_ID=$(
    aws route53 list-hosted-zones \
        --query "HostedZones[?Name=='${ZONE_NAME}'].Id | [0]" \
        --output text |
    sed 's|/hostedzone/||'
)

if [[ -z "${HOSTED_ZONE_ID}" || "${HOSTED_ZONE_ID}" == "None" ]]; then
    log_error "Hosted zone not found for ${ZONE_NAME}"
    exit 1
fi

EXPECTED_ALB_NAME=$(
    aws elbv2 describe-load-balancers \
        --query "LoadBalancers[?contains(LoadBalancerName, '${SUBDOMAIN}')].LoadBalancerName | [0]" \
        --output text
)

if [[ -z "${EXPECTED_ALB_NAME}" || "${EXPECTED_ALB_NAME}" == "None" ]]; then
    log_error "No ALB found containing '${SUBDOMAIN}'"
    exit 1
fi

EXPECTED_ALB_DNS_NAME=$(
    aws elbv2 describe-load-balancers \
        --names "${EXPECTED_ALB_NAME}" \
        --query 'LoadBalancers[0].DNSName' \
        --output text
)

EXPECTED_ALB_HOSTED_ZONE_ID=$(
    aws elbv2 describe-load-balancers \
        --names "${EXPECTED_ALB_NAME}" \
        --query 'LoadBalancers[0].CanonicalHostedZoneId' \
        --output text
)

if [[ -z "${EXPECTED_ALB_DNS_NAME}" || "${EXPECTED_ALB_DNS_NAME}" == "None" ]]; then
    log_error "Expected ALB DNS name not found"
    exit 1
fi

CHANGE_BATCH=$(
cat <<EOF
{
  "Comment": "INC-003 Route 53 Remediation",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${RECORD_NAME}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "${EXPECTED_ALB_HOSTED_ZONE_ID}",
          "DNSName": "dualstack.${EXPECTED_ALB_DNS_NAME}",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF
)

CHANGE_ID=$(
    aws route53 change-resource-record-sets \
        --hosted-zone-id "${HOSTED_ZONE_ID}" \
        --change-batch "${CHANGE_BATCH}" \
        --query 'ChangeInfo.Id' \
        --output text
)

log_info "Route 53 record restored"
log_info "Record: ${RECORD_NAME}"
log_info "Target ALB: ${EXPECTED_ALB_NAME}"
log_info "Change ID: ${CHANGE_ID}"