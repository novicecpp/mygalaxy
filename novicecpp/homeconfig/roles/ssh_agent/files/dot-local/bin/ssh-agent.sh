#!/bin/bash

IID=${1}
if [[ $IID == 'user' ]]; then
    SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.sock"
elif [[ $IID == 'forward' || $IID == 'stepca' ]]; then
    SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent-${IID}.sock"
else
    >&2 echo "Error: Instance Identifier does not recognized: ${IID}"
fi
export SSH_AUTH_SOCK

exec /usr/bin/ssh-agent -D -a "${SSH_AUTH_SOCK}"
