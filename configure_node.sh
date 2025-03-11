#!/bin/bash

set -x

function enable_crio_debug() {
    sudo sed -i -e 's/\(^log_level\).*=.*$/\1 = "debug"/g' /etc/crio/crio.conf.d/00-default
}

function enable_config_debug() {
    local config_file=$1
    sed -i -e 's/^# *\(enable_debug\).*=.*$/\1 = true/g' ${config_file}
    sed -i -e 's/^kernel_params = "\(.*\)"/kernel_params = "\1 agent.log=debug nvrc.log=debug initcall_debug"/g' ${config_file}
}

function configure_kata_nvidia() {
    local config_nvidia="/opt/kata/share/defaults/kata-containers/configuration-qemu-nvidia-gpu.toml"

    sudo cp crio.conf.d/50-kata-nvidia-gpu /etc/crio/crio.conf.d/ || exit 1
    enable_config_debug ${config_nvidia}

    # Config tweaks
    sed -i '/^#hotplug_vfio_on_root_bus/hotplug_vfio_on_root_bus/g' ${config_nvidia}
}

function configure_kata_nvidia_snp() {
    local config_nvidia_snp="/opt/kata/share/defaults/kata-containers/configuration-qemu-nvidia-gpu-snp.toml"

    sudo cp crio.conf.d/50-kata-nvidia-gpu-snp /etc/crio/crio.conf.d/ || exit 1
    enable_config_debug ${config_nvidia_snp}

    # Config tweaks
    sed -i '/^#hotplug_vfio_on_root_bus/hotplug_vfio_on_root_bus/g' ${config_nvidia_snp}
    sed -i '/^#pcie_root_port/pcie_root_port/g' ${config_nvidia_snp}
    sed -i '/^cold_plug_vfio/#cold_plug_vfio/g' ${config_nvidia_snp}
}

enable_crio_debug
configure_kata_nvidia
configure_kata_nvidia_snp

# Restart crio
sudo systemctl restart crio

echo "=== Finished successfully ==="
