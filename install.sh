#! /bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "${SCRIPT_DIR}"
BASEDIR="${HOME}/.ansible/collections/ansible_collections/"
ansible-galaxy install -r requirements.yml
if [[ ! -L "${BASEDIR}/novicecpp" ]]; then
    ln -s "${PWD}/novicecpp" "${BASEDIR}/novicecpp"
fi
popd
