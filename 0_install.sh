#!/usr/bin/env bash
set -eo pipefail

mkdir -p ./kube

if [ ! -f ./kube/config.yaml ]; then
  kind create cluster -n qhd --kubeconfig ./kube/config.yaml --config ./kind/cluster.yaml
fi

# used by humanitec-agent to reach the cluster
kind export kubeconfig --internal  -n qhd --kubeconfig ./kube/config-internal.yaml
# used by docker to reach the cluster
cp ./kube/config.yaml ./kube/config-docker.yaml
kubeconfig_docker=$(pwd)/kube/config-docker.yaml
yq '.clusters[0].cluster.server |= sub("127.0.0.1"; "docker.for.mac.localhost")' -i "$kubeconfig_docker"
yq '.clusters[0].cluster.insecure-skip-tls-verify |= true' -i "$kubeconfig_docker"
yq 'del(.clusters[0].cluster.certificate-authority-data)' -i "$kubeconfig_docker"

humctl_token=$(yq .token /root/.humctl)

export HUMANITEC_TOKEN=$humctl_token
export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker

terraform -chdir=./terraform init -upgrade
terraform -chdir=./terraform apply -auto-approve

echo ""
echo ">>>> Everything prepared, ready to deploy application."
