


### Alert setup

This is required to allow the kubeProxy to share stats with Prometheus

- kubectl edit configmaps -n kube-system kube-proxy 

change: 

- metricsBindAddress: "" 

to: 

- metricsBindAddress: 0.0.0.0:10249

see: ./monkeypatch/kubeProxy-metricsBindAddress.py

## Monitoring by hand


kubectl logs -n gateway -l app.kubernetes.io/name=nginx-gateway-fabric -c nginx