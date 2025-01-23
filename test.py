import os
import argparse
import shutil

def clean_tf():
    objs = ['.terraform', '.terraform.lock.hcl', 'terraform.tfstate', 'terraform.tfstate.backup']
    for obj in objs:
        if os.path.exists(obj):
            if os.path.isdir(obj):
                shutil.rmtree(obj)
            else:
                os.remove(obj)
    
def create_kind(cluster):
    if not kind_cluster_exists(cluster):
        os.system(f"kind create cluster --name {cluster}")

def clean_kind(cluster):
    if kind_cluster_exists(cluster):
        os.system(f"kind delete cluster --name {cluster}")

def kind_cluster_exists(cluster):
    return os.system(f"kind get clusters | grep {cluster}") == 0

def get_kubeconfig(cluster):
    print(os.system(f"kubectl cluster-info --context kind-{cluster}"))

def is_node_ready(cluster):
    # check if the node is ready
    return os.system(f'kubectl get node {cluster}-control-plane -o jsonpath="{{.status.conditions[?(@.type==\\"Ready\\")].status}}"')

def main(args):
    if args.clean:
        clean_kind(args.cluster)
        clean_tf()

    create_kind(args.cluster) 

    tf_args=f"-var=context=kind-{args.cluster}"
    os.system('tofu init')
    os.system('source .env && tofu plan {}'.format(tf_args))
    os.system('source .env && tofu apply {} -auto-approve'.format(tf_args)) 

    if args.verify:
        get_kubeconfig(args.cluster)
        print("Node is ready: ", is_node_ready(args.cluster))
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--cluster', type=str, required=True, help='Name of the cluster')
    parser.add_argument('--clean', required=False, help='Clean the cluster', action='store_true')
    parser.add_argument('--verify', required=False, help='Verify the setup', action='store_true')
    args = parser.parse_args()
    main(args)