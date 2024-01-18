#! /bin/bash

if [[ -z $GATEWAY_IP ]]; then
   >&2 echo "WARNING: '\$GATEWAY_IP' does not set. Use default '172.29.0.1'."
fi

GATEWAY_IP=${GATEWAY_IP:-172.29.0.1}

while true; do
    timeout 10s ping "${GATEWAY_IP}"
    sleep $((240 + (RANDOM % 60) ))
done
