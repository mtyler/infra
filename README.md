


### Alert setup

run the following command from the controlplane node.

kubectl create secret generic etcd-certs -n monitoring 
--from-literal=ca.crt="$(cat /etc/kubernetes/pki/etcd/ca.crt)" 
--from-literal=healthcheck-client.crt="$(sudo cat /etc/kubernetes/pki/etcd/healthcheck-client.crt)" --from-literal=healthcheck-client.key="$(sudo cat /etc/kubernetes/pki/etcd/healthcheck-client.key)"

kubectl create secret generic etcd-client-cert -n monitoring --from-literal=caFile="$(cat /etc/kubernetes/pki/etcd/ca.crt)" --from-literal=certFile="$(sudo cat /etc/kubernetes/pki/etcd/healthcheck-client.crt)" --from-literal=keyFile="$(sudo cat /etc/kubernetes/pki/etcd/healthcheck-client.key)"


k edit configmaps -n kube-system kube-proxy
metricsBindAddress: 0.0.0.0:10249