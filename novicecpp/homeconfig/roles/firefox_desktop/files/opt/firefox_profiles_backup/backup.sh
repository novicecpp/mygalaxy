#!/bin/bash
set -euo pipefail
if [[ -n ${TRACE+x} ]]; then
    set -x
    export TRACE
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# hardcode firefox profile path
#PROFILE_PATH=
#FIREFOX_PROFILE
#~/.mozilla/firefox
set -o allexport
source ~/.config/firefox_profiles_backup/env
set +o allexport
for profile in "${FIREFOX_PROFILE[@]}"; do
    profilepath=$(find "${PROFILE_PATH}" -name "*.${profile}" -type d)
    echo "backup profile \"${profile}\" on path: ${profilepath}"
    tar --zstd -cf "${BACKUP_PATH}/${profile}.tar.zst" "${profilepath}"
done
