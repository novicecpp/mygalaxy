#! /bin/bash

set -euo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ln -s "${SCRIPT_DIR}"/novicecpp ~/.ansible/collections/ansible_collections/novicecpp
