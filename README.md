
## Useful setup 

kubectl krew install rook-ceph


## Usage

1. ensure you have created a .env file in the root of the repository and it should have the following values

- export TF_VAR_slack_api_url="https://hooks.slaxxxREPLACExWITHxYOURxHOOKxx/xxxxxvzJ"



### Alert setup

This is required to allow the kubeProxy to share stats with Prometheus

- kubectl edit configmaps -n kube-system kube-proxy 

change: 

- metricsBindAddress: "" 

to: 

- metricsBindAddress: 0.0.0.0:10249

see: ./monkeypatch/kubeProxy-metricsBindAddress.py

### Monitoring setup by hand

kubectl get events -A -w

kubectl logs -n gateway -l app.kubernetes.io/name=nginx-gateway-fabric -c nginx -f

kubectl logs -l app.kubernetes.io/name=falco -n monitoring -c falco -f 

Look at disks on Node:
df -h
df -a
lsblk -f

kubectl rook-ceph ceph status


## Operations

### Access Monitoring Apps

If DNS is not configured, make sure the following is in your /etc/hosts
where the IP is the ip of a node in the cluster

192.168.5.x k8s.local graf.k8s.local prom.k8s.local alert.k8s.local sec.k8s.local dash.k8s.local

services will be available on the nodePort for example: http://graf.k8s.local:30080

Grafana Credentials
kubectl get secrets -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
kubectl get secrets -n monitoring prometheus-grafana -o jsonpath='{.data.admin-user}' | base64 --decode

Falco Creds
admin:admin


### Hygene by hand

delete all evicted pods
kubectl delete pods -A --field-selector=status.phase=Failed --wait=false

kubectl logs -l tier=control-plane --all-containers=true -n kube-system | grep -i error

rook operator labels
app=rook-ceph-operator
app=rook-discover


### Take Etcd Snapshot

kubectl exec -n kube-system [etcd pod] -- etcdctl --endpoints [etcd endpoint url] --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save [snapshot file]

k exec -n kube-system pod/etcd-cp1 -- etcdctl --endpoints https://172.16.159.131:2379 --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save /var/lib/etcd/etcd-snap-0129.db

