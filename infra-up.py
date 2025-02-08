#!/opt/homebrew/bin/python3
import os
import argparse
import shutil

def clean_tf():
    # Remove terraform stateful objects
    objs = ['.terraform', '.terraform.lock.hcl', 'terraform.tfstate', 'terraform.tfstate.backup']
    for obj in objs:
        if os.path.exists(obj):
            if os.path.isdir(obj):
                shutil.rmtree(obj)
            else:
                os.remove(obj)

def rollout(env, plan, tf_args):
    if plan:
        # Use tofu to plan and apply tf scripts
        plan_command = f'source {env} && tofu plan -concise {tf_args}'
        plan_result = os.system(plan_command)
        if plan_result != 0:
            print("Error: 'tofu plan' command failed with exit code", plan_result)
            exit(1)
        os.system(f'source {env} && tofu apply -concise {tf_args}')
    else:
        print("Converging cluster with shortcuts, use --plan to avoid auto-approve")
        os.system(f'source {env} && tofu apply -concise {tf_args} -auto-approve -compact-warnings')

def converge(args):
    if args.clean:
        print("Cleaning terraform stateful objects")
        clean_tf()

    # plan and apply the gateway module to lay down CRDs
    # https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
    if args.init:
        print("Initialize tofu")
        os.system('tofu init -upgrade')

        print("Initialize cluster by applying CRDs")
        rollout(args.env, args.plan, f"-var=context={args.context} -target=module.gateway")
        rollout(args.env, args.plan, f"-var=context={args.context} -target=module.cert_manager")
#         print("Run monkeypatch...")
#         os.system("python3 ./monkeypatch/kubeProxy-metricsBindAddress.py")
#        print("!! Warning !! CRD modules applied ONLY")
#        return        
    
    if args.run != None:
        print("Running with arbitrary command injection")
        rollout(args.env, args.plan, f"-var=context={args.context} {args.run}")
        print("Command complete.")
        return

    print("Begin cluster convergence")
    rollout(args.env, args.plan, f"-var=context={args.context}")
    print("Cluster converged")

def main():
    parser = argparse.ArgumentParser(description="Setup a k8s cluster in vagrant")
    parser.add_argument('--context', type=str, default="kubernetes-admin@kubernetes", help='Name of the cluster')
    parser.add_argument('--init', required=False, help='Converge crds before the cluster', action='store_true')
    parser.add_argument('--clean', required=False, help='Clean the cluster', action='store_true')
    parser.add_argument('--env', type=str, default="./envs/dev/.env", help='path of the environment file')
    parser.add_argument('--plan', required=False, help='Do not auto approve the plan', action='store_true')
    parser.add_argument('--run', type=str, help='Run a custom command, e.g. --run="-var=foo=bar"')
    args = parser.parse_args()
    
    converge(args)
        
    print("Nothing left to do. Goodbye.")

# Begin program
if __name__ == "__main__":
    main()