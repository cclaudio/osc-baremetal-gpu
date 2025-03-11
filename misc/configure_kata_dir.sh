#!/bin/bash

KATA_DIR=${1:-/opt/kata}

read -p "Configure ${KATA_DIR}[y/N]?" confirm && [[ $confirm == [yY] ]] || exit 1

sudo rm /opt/kata || exit 1
sudo ln -s ${KATA_DIR} kata || exit 1

echo "Configuring ${KATA_DIR} selinux attributes"
pushd ${KATA_DIR}
chcon -R system_u:object_r:usr_t:s0 . || exit 1
chcon -R system_u:object_r:lib_t:s0 lib || exit 1
chcon -R system_u:object_r:bin_t:s0 bin || exit 1
popd

echo "=== Finished successfully ==="
