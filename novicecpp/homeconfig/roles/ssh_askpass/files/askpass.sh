#!/bin/bash

set -euo pipefail

# require env (see f_ssh_add()),
[[ -v PASS_KEY_PATH ]] || echo "PASS_KEY_PATH is not set." >&2
[[ -v ATTEMPT_FILE ]] || echo "ATTEMPT_FILE is not set." >&2

if [[ -f "$ATTEMPT_FILE" ]]; then
    rm -f "$ATTEMPT_FILE"
    echo "Error: The password already provided. Please check passphrase from \"${PASS_KEY_PATH}\". Exiting..." >&2
    exit 1
else
    PASSPHRASE="$(pass show ${PASS_KEY_PATH})"
    if [[ -z "${PASSPHRASE}" ]]; then
        echo "Error: password is empty." >&2
        exit 1
    else
        touch "${ATTEMPT_FILE}"
        echo "${PASSPHRASE}"
    fi
fi
