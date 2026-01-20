#! /bin/bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
    endpoint_ip=$(dig +https +short @9.9.9.9 ${hostname})
    if [[ $endpoint_ip == 'null' ]]; then
        >&2 echo "Error: Domain not found: ${hostname}"
        exit 1;
    fi
    echo "${endpoint_ip}"
}

interface=${1} # e.g., `wg-internal`
mode=${2} # `postup` or `predown`
postup_mode=${3:-} # `client` or `server`
wireguard_endpoint=${4:-} # wireguard.example.com:13192

hostname=$(echo "${wireguard_endpoint}" | cut -d: -f1)
port=$(echo "${wireguard_endpoint}" | cut -d: -f2)
configdir=/etc/wireguard/${interface}.d
POSTUP_SH="${configdir}/postup.sh"
PREDOWN_SH="${configdir}/predown.sh"
if [[ ${mode} == 'postup' ]]; then

    if [[ ${postup_mode} == client ]]; then
        # peer pub key is required for endpoint
        if ipvalid "${hostname}"; then
            endpoint_hostname="${hostname}"
        else
            endpoint_hostname=$(resolvedns "${hostname}")
        fi
        endpoint=${endpoint_hostname}:${port}

        # peer pubkey required by wg set command
        wg set "${interface}" peer "$(cat "${configdir}"/peer.pub)" endpoint "${endpoint}"
    elif  [[ ${postup_mode} == server ]]; then
	    :
    else
	>&2 echo "Error: unrecognize post-up mode \"${mode}\""
    fi
    wg set "${interface}" private-key <(cat "${configdir}/${interface}.key");

    #
    POSTUP_SH="${configdir}/postup.sh"
    if [[ -f $POSTUP_SH ]]; then
        bash ${POSTUP_SH} ${interface}
    else
	>&2 echo "Postup script does not exists: ${PREDOWN_SH}. Do nothing."
    fi
elif [[ ${mode} == 'predown' ]]; then
    resolvectl revert ${interface}
    if [[ -f $PREDOWN_SH ]]; then
        bash ${PREDOWN_SH} ${interface}
    else
        >&2 echo "Predown script does not exists: ${PREDOWN_SH}. Do nothing."
    fi
else
    >&2 echo "Error: unrecognize mode \"${mode}\""
    exit 1
fi
