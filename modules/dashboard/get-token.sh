#!/bin/bash
# get token to log into dashboard
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

# get token to log into grafana
kubectl get secrets -n monitoring prometheus-grafana -o jsonpath={".data.admin-password"} | base64 -d