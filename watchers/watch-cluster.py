import argparse
import os
import time
import subprocess
import signal
import sys
import threading

#pause_flag = False
#pause_lock = threading.Lock()

def get_namespaces():
    result = subprocess.run(['kubectl', 'get', 'ns', '-o', 'jsonpath={.items[*].metadata.name}'], capture_output=True, text=True)
    namespaces = result.stdout.split()
    return namespaces

def get_nodes():
    result = subprocess.run(['kubectl', 'get', 'no', '-o', 'jsonpath={.items[*].metadata.name}'], capture_output=True, text=True)
    nodes = result.stdout.split()
    return nodes

def view(title, show_me, interval, ask):
    #create an absraction layer that enables the user to refresh the current screen or continue
    os.system('clear')
    print(title)
    for each in show_me:
        print(f"\n{each[0]}")
        if isinstance(each[1], list):
            subprocess.run(each[1])
        else:
            subprocess.run(each[1], shell=True)
    
    cmd = rest(interval, ask)
    if cmd == 'r':
        view(title, show_me, interval, ask)

def watch_pods(args):
    while True:
        namespaces = get_namespaces()
        for ns in namespaces:
            show_me = []
            show_me.append(("Pods:", ['kubectl', 'get', 'po', '-n', ns, '-o', 'wide']))
            show_me.append(("Deployments:", ['kubectl', 'get', 'deploy', '-n', ns, '-o', 'wide']))
            show_me.append(("Services:", ['kubectl', 'get', 'svc', '-n', ns, '-o', 'wide']))
            view(f'Namespace: {ns}', show_me, args.interval, args.ask)
        
        show_me = []
        show_me.append(("Cluster Info:", ['kubectl', 'cluster-info']))
        show_me.append(("Nodes:", ['kubectl', 'get', 'no', '-o', 'wide']))
        show_me.append(("Conditions:", ['kubectl', 'get', 'no', '-o', 'jsonpath={range .items[*]}{.metadata.name}{": "}{range .status.conditions[*]}{.type}{"="}{.status}{" "}{end}{"\\n"}{end}']))
        show_me.append(("Allocated Resources (describe):", r"kubectl describe nodes | grep 'Name:\\|Allocated' -A 8 | grep 'Name:\\|Allocated\\|cpu\\|memory'"))
        ## Uncomment to display allocated resources as displayed in the node status object
        #show_me.append(("Allocated Resources:", ['kubectl', 'get', 'no', '-o', 'jsonpath={range .items[*]}{.metadata.name}{": cpu "}{.status.allocatable.cpu}{" mem "}{.status.allocatable.memory}{" eph-storage "}{.status.allocatable.ephemeral-storage}{"\\n"}{end}']))
        view('Cluster Overview', show_me, args.interval, args.ask)

def watch_nodes(args):
    while True:
        nodes = get_nodes()
        for node in nodes:
            os.system('clear')
            print(f'Node: {node}')
            print("\nPods:")
            subprocess.run(['kubectl', 'get', 'po', '--field-selector=spec.nodeName={}'.format(node), '-o', 'wide', '-A'])
            rest(args)

        os.system('clear')
        subprocess.run(['kubectl', 'top', 'no'])
        rest(args)
        os.system('clear')
        subprocess.run(['kubectl', 'top', 'po', '--containers', '-A'])
        rest(args)        

def rest(interval, ask):
    cmd = ''
    if ask:
        cmd = input("\nCtrl+c exit | r+Enter refresh | Press Enter to continue:")
    else:
        time.sleep(interval)
    return cmd
    
def signal_handler(sig, frame): 
    sys.exit(0)

def print_to_log(message):
    log_file_path = os.path.join(os.path.dirname(__file__), 'watch-all-pods.log')
    with open(log_file_path, 'a') as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")

def parse_args():
    parser = argparse.ArgumentParser(description='Watch all pods in all namespaces.')
    parser.add_argument('--nodes', '-n', action='store_true', help='Watch all pods on all nodes')
    parser.add_argument('--interval', '-i', type=int, default=5, help='Interval between checks in seconds (default: 5)')
    parser.add_argument('--ask', action='store_true', help='Ask for confirmation before each iteration (default: False)')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    REST = args.interval
    if args.ask:
        pause_flag = True

    signal.signal(signal.SIGINT, signal_handler)

    if args.nodes:
        watch_nodes(args)
    else:
        watch_pods(args)