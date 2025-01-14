#!/bin/bash
# get token to log into dashboard
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d