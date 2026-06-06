#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

HOSTNAME="${1:-}"

if [[ -z "${HOSTNAME}" ]]; then
    log_error "Usage: $0 <hostname>"
    exit 1
fi

log_info "Validating certificate hostname match: ${HOSTNAME}"

if openssl s_client \
    -connect "${HOSTNAME}:443" \
    -servername "${HOSTNAME}" \
    -verify_hostname "${HOSTNAME}" \
    -verify_return_error \
    </dev/null \
    >/dev/null 2>&1; then
    log_info "Certificate validation succeeded"
    exit 0
fi

log_error "Certificate validation failed"
exit 1
