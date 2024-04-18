#!/usr/bin/env bash
set -eo pipefail

humctl_token=$(yq .token /root/.humctl)
kubeconfig_docker=$(pwd)/kube/config-docker.yaml

export HUMANITEC_TOKEN=$humctl_token
export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker


if humctl get application qhd; then
  humctl delete application qhd
fi

terraform -chdir=./terraform destroy -auto-approve

kind delete cluster -n qhd

rm -rf ./kube
