#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

HOSTNAME="${1:-}"
PRODUCTION_ALB_NAME="${PRODUCTION_ALB_NAME:-}"

if [[ -z "${HOSTNAME}" || -n "${2:-}" ]]; then
    log_error "Usage: $0 <production-domain>"
    exit 1
fi

if [[ -z "${PRODUCTION_ALB_NAME}" ]]; then
    log_error "Set PRODUCTION_ALB_NAME before running this script"
    exit 1
fi

log_info "Inspecting HTTPS listeners for hostname: ${HOSTNAME}"
log_info "Production Load Balancer: ${PRODUCTION_ALB_NAME}"

if ! PRODUCTION_ALB_ARN=$(
    aws elbv2 describe-load-balancers \
        --names "${PRODUCTION_ALB_NAME}" \
        --query 'LoadBalancers[0].LoadBalancerArn' \
        --output text
); then
    log_error "ALB Listener Misconfiguration cannot be evaluated: production ALB not found"
    exit 1
fi

if [[ -z "${PRODUCTION_ALB_ARN}" || "${PRODUCTION_ALB_ARN}" == "None" ]]; then
    log_error "ALB Listener Misconfiguration cannot be evaluated: production ALB not found"
    exit 1
fi

LISTENER_ARN=$(
    aws elbv2 describe-listeners \
        --load-balancer-arn "${PRODUCTION_ALB_ARN}" \
        --query 'Listeners[?Port==`443`].ListenerArn | [0]' \
        --output text
)

if [[ -z "${LISTENER_ARN}" || "${LISTENER_ARN}" == "None" ]]; then
    log_error "ALB Listener Misconfiguration confirmed: production HTTPS listener not found"
    exit 1
fi

for CERTIFICATE_ARN in $(aws elbv2 describe-listener-certificates \
    --listener-arn "${LISTENER_ARN}" \
    --query 'Certificates[].CertificateArn' \
    --output text); do

    log_info "Attached certificate: ${CERTIFICATE_ARN}"

    CERTIFICATE_NAMES=$(
        aws acm describe-certificate \
            --certificate-arn "${CERTIFICATE_ARN}" \
            --query 'Certificate.SubjectAlternativeNames[]' \
            --output text
    )

    for CERTIFICATE_NAME in ${CERTIFICATE_NAMES}; do
        if [[ "${CERTIFICATE_NAME}" == "${HOSTNAME}" ]]; then
            log_info "ALB Listener Misconfiguration discarded: production listener certificate covers ${HOSTNAME}"
            exit 0
        fi
    done
done

log_error "ALB Listener Misconfiguration confirmed: production listener certificate does not cover ${HOSTNAME}"
exit 1
