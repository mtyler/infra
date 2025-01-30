import os
import time
import subprocess
import signal
import sys

def get_namespaces():
    result = subprocess.run(['kubectl', 'get', 'ns', '-o', 'jsonpath={.items[*].metadata.name}'], capture_output=True, text=True)
    namespaces = result.stdout.split()
    return namespaces

def watch_pods():
    while True:
        namespaces = get_namespaces()
        for ns in namespaces:
            os.system('clear')
            subprocess.run(['kubectl', 'get', 'po', '-n', ns, '-o', 'wide'])
            time.sleep(3)

def signal_handler(sig, frame): 
    sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    watch_pods()