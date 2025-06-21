#!/bin/bash

set -euo pipefail

ATTEMPT_COUNT_FILE="/tmp/askpass_count_u$(id -u).txt"
# use PASSPATH_SSH_KEY define in home-config/private
PASSPATH_SSH_KEY=${PASSPATH_SSH_KEY:-probe}
MAX_ATTEMPTS=3

if [ -f "$ATTEMPT_COUNT_FILE" ]; then
    CURRENT_ATTEMPTS=$(cat "${ATTEMPT_COUNT_FILE}")
else
    CURRENT_ATTEMPTS=0
fi

CURRENT_ATTEMPTS=$(( CURRENT_ATTEMPTS + 1 ))
echo "${CURRENT_ATTEMPTS}" > "${ATTEMPT_COUNT_FILE}"

if [[ "$CURRENT_ATTEMPTS" -gt "$MAX_ATTEMPTS" ]]; then
    rm -f "$ATTEMPT_COUNT_FILE"
    echo "Error: Maximum password attempts exceeded. Exiting..." >&2
    exit 1
else
    PASSPHRASE="$(pass show ${PASSPATH_SSH_KEY})"
    if [[ -z "${PASSPHRASE}" ]]; then
        echo "Error: password is empty." >&2
        rm -f "${ATTEMPT_COUNT_FILE}"
        exit 1
    else
        echo "${PASSPHRASE}"
    fi
fi
