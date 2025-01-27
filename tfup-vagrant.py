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

def rollout(tf_args):
    plan_command = 'source .env && tofu plan -concise {}'.format(tf_args)
    plan_result = os.system(plan_command)
    if plan_result != 0:
        print("Error: 'tofu plan' command failed with exit code", plan_result)
        exit(1)
    os.system('source .env && tofu apply -concise {} -auto-approve'.format(tf_args))

def converge(args):
    # intialize tofu
    os.system('tofu init')
    # plan and apply the gateway module to lay down CRDs
    # https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
    if args.crdprep:
         rollout(f"-var=context={args.context} -target=module.gateway")

    print("Gateway module applied with CRDs")
    rollout(f"-var=context={args.context}")

def main():
    parser = argparse.ArgumentParser(description="Setup a k8s cluster in vagrant")
    parser.add_argument('--context', type=str, default="kubernetes-admin@kubernetes", help='Name of the cluster')
    parser.add_argument('--converge', required=False, help='Converge the cluster', action='store_true')
    parser.add_argument('--crdprep', required=False, help='Converge crds before the cluster', action='store_true')
    parser.add_argument('--clean', required=False, help='Clean the cluster', action='store_true')
    args = parser.parse_args()
    if args.clean:
        clean_tf()
    
    if args.converge:
        converge(args)

# Begin program
if __name__ == "__main__":
    main()