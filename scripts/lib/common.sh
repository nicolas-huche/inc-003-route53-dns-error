#!/usr/bin/env bash

timestamp_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log_info() {
    local message="$1"

    printf "[INFO] %s %s\n" "$(timestamp_utc)" "${message}"
}

log_warn() {
    local message="$1"

    printf "[WARN] %s %s\n" "$(timestamp_utc)" "${message}"
}

log_error() {
    local message="$1"

    printf "[ERROR] %s %s\n" "$(timestamp_utc)" "${message}" >&2
}