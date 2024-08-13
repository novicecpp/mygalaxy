#! /bin/bash

set -euo pipefail

# https://stackoverflow.com/questions/13777387/check-for-ip-validity
ipvalid() {
    # Set up local variables
    local ip=${1:-NO_IP_PROVIDED}
    local IFS=.;
    # shellcheck disable=SC2206
    local -a a=(${ip})
    # Start with a regex format test
    [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
    # Test values of quads
    local quad
    for quad in {0..3}; do
        [[ "${a[$quad]}" -gt 255 ]] && return 1
    done
    return 0
}

resolvedns() {
    local endpoint_ip
    local hostname=$1
    endpoint_ip=$(curl -s --tlsv1.3 --http2 -H "accept: application/dns-json" "https://1.1.1.1/dns-query?name=${hostname}" | jq .Answer[0].data -r)
    if [[ $endpoint_ip == 'null' ]]; then
        >&2 echo "Error: Domain not found: ${hostname}"
        exit 1;
    fi
    echo "${endpoint_ip}"
}

interface=$1 # e.g., `wg-internal`
mode=$2 # `client` or `server`
dns_endpoint=${3:-} # wireguard.example.com:13192

hostname=$(echo "${dns_endpoint}" | cut -d: -f1)
port=$(echo "${dns_endpoint}" | cut -d: -f2)
configdir=/etc/wireguard/${interface}.d

if [[ ${mode} == client ]]; then
    # peer pub key is required for endpoint
    if ipvalid "${hostname}"; then
        endpoint_hostname="${hostname}"
    else
        endpoint_hostname=$(resolvedns "${hostname}")
    fi
    endpoint=${endpoint_hostname}:${port}

    # peer pubkey required by wg set command
    wg set "${interface}" peer "$(cat "${configdir}"/peer.pub)" endpoint "${endpoint}"
fi
wg set "${interface}" private-key <(cat "${configdir}/${interface}.key");
