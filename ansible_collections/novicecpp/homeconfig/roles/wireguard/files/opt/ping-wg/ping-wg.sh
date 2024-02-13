#! /bin/bash
# Ping GATEWAY_IP every 30-60 seconds.
# Retry 3 times (cooldown 10 seconds) before exit with error.

if [[ -z $GATEWAY_IP ]]; then
   >&2 echo "WARNING: '\$GATEWAY_IP' does not set. Use default '172.29.0.1'."
fi

GATEWAY_IP=${GATEWAY_IP:-172.29.0.1}

while true; do
    for ((i=1;i<=3;i++)); do
        ping -c5 "${GATEWAY_IP}" || rc=$?
        if [[ -z $rc ]]; then
            break;
        fi
        if [[ $i == 3 ]]; then
            echo "Error: Maximum ping retry is reached."
            exit 1;
        fi
        echo "Fail to ping ${GATEWAY_IP}. Retrying in 10 seconds (${i}/3)."
        sleep 10
    done
    SLEEPSECONDS=$((30 + (RANDOM % 30)))
    echo "Ping sucessfully. Sleeping $SLEEPSECONDS seconds."
    sleep $SLEEPSECONDS
done
