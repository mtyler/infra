#!/bin/sh

# stop on error
set -e

# Function to display usage
usage() {
  echo "Usage: $0 [clean]"
  exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -gt 1 ]; then
  echo "Error: Invalid number of arguments"
  usage
fi

# Check if the argument is "clean" if provided
if [ "$#" -eq 1 ] && [ "$1" != "clean" ]; then
  echo "Error: Invalid argument"
  usage
fi

CLUSTER="kind-test"

# kind delete cluster $CLUSTER
if [ "$1" = "clean" ]; then
  echo "removing terraform state..."
  rm -f ./*.tfstate*
  rm -f ./.terraform.lock.hcl
  rm -rf ./.terraform
  echo "removing cluster..."
  kind delete clusters $CLUSTER || true
fi

# create cluster if it's not accessible
if [ "$(kind get clusters)" != $CLUSTER ]; then
  echo "creating cluster..."
  kind create cluster --name $CLUSTER --config ./envs/kind-cluster/cluster-config.yaml
fi
ARGS="-var=context=kind-${CLUSTER}"

# terraform deployment
tofu init && tofu plan $ARGS && tofu apply $ARGS -auto-approve > last-run.log 2>&1

## TODO - test
## TODO - cleanup