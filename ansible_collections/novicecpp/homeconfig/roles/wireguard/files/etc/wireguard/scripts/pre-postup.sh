#! /bin/bash

set -euo pipefail

interface=$1 # e.g., `wg-internal`
mode=$2 # `client` or `server`
dns_endpoint=${3:-} # kaguya.novicecpp.net:22441
configdir=/etc/wireguard/${interface}.d/
if [[ ${mode} == client ]]; then
    hostname=$(echo $dns_endpoint | cut -d: -f1)
    endpoint_ip=$(curl -s --tlsv1.3 --http2 -H "accept: application/dns-json" "https://1.1.1.1/dns-query?name=${hostname}" | jq .Answer[0].data -r)
    if [[ $endpoint_ip == 'null' ]]; then
        >&2 echo "Domain not found: ${hostname}"
        exit 1;
    fi
    wg set ${interface} peer $(cat ${configdir}/peer.pub) endpoint ${dns_endpoint}
fi
wg set ${interface} private-key <(cat ${configdir}/${interface}.key);
