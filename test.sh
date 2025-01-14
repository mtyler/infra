#!/bin/sh

# stop on error
set -e

CLUSTER="kind-test"
## TODO - preflight checks/clean
# kind delete cluster $CLUSTER

# is cluster accessible
if [ "$(kind get clusters)" != $CLUSTER ]; then
  echo "removing terraform state..."
  rm -f ./*.tfstate*
  rm -f ./.terraform.lock.hcl
  rm -rf ./.terraform
  echo "creating cluster..."
  kind create cluster --name $CLUSTER --config ./envs/kind-cluster/cluster-config.yaml
fi

#tofu -chdir=../gateway init
ARGS="-var=context=kind-${CLUSTER}"
tofu init && tofu plan $ARGS && tofu apply $ARGS -auto-approve


## TODO - test
## TODO - cleanup