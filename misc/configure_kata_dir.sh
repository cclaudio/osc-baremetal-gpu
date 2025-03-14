#!/bin/bash

set -x

KATA_DIR=${1}

[ -d ${KATA_DIR} ] || { echo "${KATA_DIR} not valid"; exit 1; }

echo "Fix /opt/kata symlink"
[ -e /opt/kata ] && sudo rm /opt/kata
sudo ln -s ${KATA_DIR} /opt/kata || exit 1

echo "Configuring ${KATA_DIR} selinux attributes"
pushd ${KATA_DIR}
chcon -R system_u:object_r:usr_t:s0 . || exit 1
chcon -R system_u:object_r:lib_t:s0 lib || exit 1
chcon -R system_u:object_r:bin_t:s0 bin || exit 1
popd

echo "=== Finished successfully ==="
