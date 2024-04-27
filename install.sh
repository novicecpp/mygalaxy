#! /bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "${SCRIPT_DIR}"
ansible-galaxy install -r requirements.yml
if [[ ! -L "${HOME}/.ansible/collections/ansible_collections/novicecpp" ]]; then
    ln -s "${PWD}"/novicecpp "${HOME}/.ansible/collections/ansible_collections/novicecpp"
fi
popd
