
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

## Monitoring by hand

kubectl get events -A -w

kubectl logs -n gateway -l app.kubernetes.io/name=nginx-gateway-fabric -c nginx -f

kubectl logs -l app.kubernetes.io/name=falco -n monitoring -c falco -f 

Look at disks on Node:
df -h
df -a
lsblk -f

## Hygene by hand

delete all evicted pods
kubectl delete pods -A --field-selector=status.phase=Failed --wait=false

k logs -l tier=control-plane --all-containers=true -n kube-system | grep -i error

rook operator labels
app=rook-ceph-operator
app=rook-discover


## Take Etcd Snapshot

kubectl exec -n kube-system [etcd pod] -- etcdctl --endpoints [etcd endpoint url] --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save [snapshot file]

k exec -n kube-system pod/etcd-cp1 -- etcdctl --endpoints https://172.16.159.131:2379 --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save /var/lib/etcd/etcd-snap-0129.db


## rook notes

mtyler@Mikes-MacBook-Pro-2 infra % k logs -n rook-ceph-cluster pods/rook-ceph-detect-version-nh5nz init-copy-binaries
unable to retrieve container logs for containerd://104cc827e372d19a52c7622385e6ded4967e7f660e87ceb89456a8e2eafdf6ba%
mtyler@Mikes-MacBook-Pro-2 infra % k logs -n rook-ceph-cluster pods/rook-ceph-detect-version-nh5nz cmd-reporter
Error from server (BadRequest): container "cmd-reporter" in pod "rook-ceph-detect-version-nh5nz" is terminated