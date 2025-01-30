


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


## Take Etcd Snapshot

kubectl exec -n kube-system [etcd pod] -- etcdctl --endpoints [etcd endpoint url] --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save [snapshot file]

k exec -n kube-system pod/etcd-cp1 -- etcdctl --endpoints https://172.16.159.131:2379 --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key --cacert /etc/kubernetes/pki/etcd/ca.crt snapshot save /var/lib/etcd/etcd-snap-0129.db