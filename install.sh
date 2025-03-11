#!/bin/bash

CMD_TIMEOUT="${CMD_TIMEOUT:-900}"

# Function to wait for the operator deployment object to be ready
function wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    local timeout=$CMD_TIMEOUT
    local interval=5
    local elapsed=0
    local ready=0

    while [ $elapsed -lt "$timeout" ]; do
        ready=$(oc get deployment -n "$namespace" "$deployment" -o jsonpath='{.status.readyReplicas}')
        if [ "$ready" == "1" ]; then
            echo "Operator $deployment is ready"
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "Operator $deployment is not ready after $timeout seconds"
    return 1
}

# Function to wait for the operator deployment object to be ready
function wait_for_clusterpolicy() {
    local clusterpolicy=$1
    local timeout=$CMD_TIMEOUT
    local interval=5
    local elapsed=0
    local ready=0

    while [ $elapsed -lt "$timeout" ]; do
        ready=$(oc get clusterpolicy "$clusterpolicy" -o jsonpath='{.status.state}')
        if [ "$ready" == "ready" ]; then
            echo "ClusterPolicy $clusterpolicy is ready"
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "Operator $deployment is not ready after $timeout seconds"
    return 1
}
function apply_operator_manifests() {
    pushd gpu-operator
    oc apply -f ns.yaml || return 1
    oc apply -f og.yaml || return 1
    # https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/install-gpu-ocp.html
    oc apply -f subs-ga.yaml || return 1
    popd
}

function deploy_nvidia_operator() {
    apply_operator_manifests || return 1
    wait_for_deployment gpu-operator nvidia-gpu-operator || return 1
    echo "=== Red Hat NVIDIA GPU Operator v22.9.2 installed ==="
}

function deploy_nvidia_cluster_policy() {
    pushd gpu-operator
    #oc get csv -n nvidia-gpu-operator gpu-operator-certified.v24.9.2 -ojsonpath={.metadata.annotations.alm-examples} | jq .[0] > nvidia-clusterpolicy.json
    oc apply -f nvidia-clusterpolicy.json || return 1
    wait_for_clusterpolicy gpu-cluster-policy || return 1
    popd
    echo "=== NVIDIA cluster policy installed ==="
}


# Install operator and cluster policy
deploy_nvidia_operator || exit 1
deploy_nvidia_cluster_policy || exit 1

oc apply -f runtimeclass/kata-nvidia-gpu-cc.yaml || exit 1
oc apply -f runtimeclass/kata-nvidia-gpu.yaml || exit 1

echo "=== Finished successfully ==="
echo "=== Now, run ./configure_node.sh on each node =="
