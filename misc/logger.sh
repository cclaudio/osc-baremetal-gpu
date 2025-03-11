#!/bin/bash

# Arguments
CRI0_HANDLER=$1

set -xe

[ ! -f "$CRI0_HANDLER" ] && { echo "CRIO handler not found. Please provide the crio handler e.g. $0 /etc/crio/crio.conf.d/50-kata-nvidia-gpu-snp"; exit 1; }

OUTPUT_DIR=$(date +"%Y-%m-%d__%H-%M-%S")
mkdir -p ${OUTPUT_DIR}
pushd ${OUTPUT_DIR}

# crio config
cp "$CRI0_HANDLER" .

# kata config
config=$(grep "^runtime_config_path" "$CRI0_HANDLER" | awk -F'=' '/=/{gsub(/"/,"",$2);gsub(/ /,"",$2); print $2}')
cp $config .

# host kernel version
uname -a > uname.txt

# kata
readlink /opt/kata > kata.txt

echo "press CTRL+C to finish"
sudo journalctl -xef > journal.log

popd

exit 0
