#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

PRODUCTION_HOSTNAME="${1:-}"
STAGING_HOSTNAME="${2:-}"

if [[ -z "${PRODUCTION_HOSTNAME}" || -z "${STAGING_HOSTNAME}" || -n "${3:-}" ]]; then
    log_error "Usage: $0 <production-domain> <staging-domain>"
    exit 1
fi

PRODUCTION_RECORD="${PRODUCTION_HOSTNAME%.}."
STAGING_RECORD="${STAGING_HOSTNAME%.}."
ZONE_NAME="$(printf "%s" "${PRODUCTION_RECORD}" | cut -d'.' -f2-)"

log_info "Injecting INC-003 Route 53 failure"
log_info "Production record: ${PRODUCTION_RECORD}"
log_info "Staging record: ${STAGING_RECORD}"

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

TARGET_DNS_NAME=$(
    aws route53 list-resource-record-sets \
        --hosted-zone-id "${HOSTED_ZONE_ID}" \
        --query "ResourceRecordSets[?Name=='${STAGING_RECORD}' && Type=='A'].AliasTarget.DNSName | [0]" \
        --output text
)

TARGET_HOSTED_ZONE_ID=$(
    aws route53 list-resource-record-sets \
        --hosted-zone-id "${HOSTED_ZONE_ID}" \
        --query "ResourceRecordSets[?Name=='${STAGING_RECORD}' && Type=='A'].AliasTarget.HostedZoneId | [0]" \
        --output text
)

if [[ -z "${TARGET_DNS_NAME}" || "${TARGET_DNS_NAME}" == "None" ]]; then
    log_error "A alias target not found for ${STAGING_RECORD}"
    exit 1
fi

CHANGE_BATCH=$(
cat <<EOF
{
  "Comment": "INC-003 Failure Injection",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${PRODUCTION_RECORD}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "${TARGET_HOSTED_ZONE_ID}",
          "DNSName": "${TARGET_DNS_NAME}",
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

log_warn "Route 53 Misconfiguration injected"
log_warn "${PRODUCTION_RECORD} now points to the same endpoint as ${STAGING_RECORD}"
log_info "Route 53 change id: ${CHANGE_ID}"
