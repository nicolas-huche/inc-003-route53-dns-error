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

log_info "Inspecting Route 53 record: ${RECORD_NAME}"

HOSTED_ZONE_ID=$(
    aws route53 list-hosted-zones \
        --query "HostedZones[?Name=='${ZONE_NAME}'].Id | [0]" \
        --output text |
    sed 's|/hostedzone/||'
)

if [[ -z "${HOSTED_ZONE_ID}" || "${HOSTED_ZONE_ID}" == "None" ]]; then
    log_error "Route 53 Misconfiguration confirmed: hosted zone not found for ${ZONE_NAME}"
    exit 1
fi

ACTUAL_ALB_DNS_NAME=$(
    aws route53 list-resource-record-sets \
        --hosted-zone-id "${HOSTED_ZONE_ID}" \
        --query "ResourceRecordSets[?Name=='${RECORD_NAME}' && Type=='A'].AliasTarget.DNSName | [0]" \
        --output text
)

if [[ -z "${ACTUAL_ALB_DNS_NAME}" || "${ACTUAL_ALB_DNS_NAME}" == "None" ]]; then
    log_error "Route 53 Misconfiguration confirmed: A alias record not found"
    exit 1
fi

ACTUAL_ALB_DNS_NAME="${ACTUAL_ALB_DNS_NAME%.}"
ACTUAL_ALB_DNS_NAME="${ACTUAL_ALB_DNS_NAME#dualstack.}"

EXPECTED_ALB_NAME=$(
    aws elbv2 describe-load-balancers \
        --query "LoadBalancers[?contains(LoadBalancerName, '${SUBDOMAIN}')].LoadBalancerName | [0]" \
        --output text
)

if [[ -z "${EXPECTED_ALB_NAME}" || "${EXPECTED_ALB_NAME}" == "None" ]]; then
    log_error "Route 53 Misconfiguration cannot be evaluated: no ALB found containing '${SUBDOMAIN}'"
    exit 1
fi

EXPECTED_ALB_DNS_NAME=$(
    aws elbv2 describe-load-balancers \
        --names "${EXPECTED_ALB_NAME}" \
        --query 'LoadBalancers[0].DNSName' \
        --output text
)

if [[ -z "${EXPECTED_ALB_DNS_NAME}" || "${EXPECTED_ALB_DNS_NAME}" == "None" ]]; then
    log_error "Route 53 Misconfiguration cannot be evaluated: expected ALB not found"
    exit 1
fi

EXPECTED_ALB_DNS_NAME="${EXPECTED_ALB_DNS_NAME#dualstack.}"

if [[ "${ACTUAL_ALB_DNS_NAME}" == "${EXPECTED_ALB_DNS_NAME}" ]]; then
    log_info "Route 53 Misconfiguration discarded: record points to the expected ALB"
    exit 0
fi

log_error "Route 53 Misconfiguration confirmed: record points to the wrong ALB"
exit 1