#!/bin/bash

set -x

# Install kata-nvidia-gpu-snp

CONFIG_NVIDIA_SNP=/opt/kata/share/defaults/kata-containers/configuration-qemu-nvidia-gpu-snp.toml

sudo cp crio.conf.d/50-kata-nvidia-gpu-snp /etc/crio/crio.conf.d/ || exit 1

# Enable full debug
sed -i -e 's/^# *\(enable_debug\).*=.*$/\1 = true/g' ${CONFIG_NVIDIA_SNP}
sed -i -e 's/^kernel_params = "\(.*\)"/kernel_params = "\1 agent.log=debug nvrc.log=debug initcall_debug"/g' ${CONFIG_NVIDIA_SNP}

# Config tweaks
sed -i '/^#hotplug_vfio_on_root_bus/hotplug_vfio_on_root_bus/g' ${CONFIG_NVIDIA_SNP}
sed -i '/^#pcie_root_port/pcie_root_port/g' ${CONFIG_NVIDIA_SNP}
sed -i '/^cold_plug_vfio/#cold_plug_vfio/g' ${CONFIG_NVIDIA_SNP}

# Restart crio
sudo systemctl restart crio

echo "=== Finished successfully ==="
