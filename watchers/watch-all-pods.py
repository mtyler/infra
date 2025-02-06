#!/usr/bin/env python3
import os
import time
import subprocess
import signal
import sys
import threading


pause_flag = False
pause_lock = threading.Lock()

def get_namespaces():
    result = subprocess.run(['kubectl', 'get', 'ns', '-o', 'jsonpath={.items[*].metadata.name}'], capture_output=True, text=True)
    namespaces = result.stdout.split()
    return namespaces

def watch_pods():
    while True:
        namespaces = get_namespaces()
        for ns in namespaces:
            os.system('clear')
            print(f'Namespace: {ns}')
            print("\nPods:")
            subprocess.run(['kubectl', 'get', 'po', '-n', ns, '-o', 'wide'])
            print("\nDeployments:")
            subprocess.run(['kubectl', 'get', 'deploy', '-n', ns, '-o', 'wide'])
            print("\nServices:")
            subprocess.run(['kubectl', 'get', 'svc', '-n', ns, '-o', 'wide'])
            rest()

        os.system('clear')
        subprocess.run(['kubectl', 'cluster-info'])
        subprocess.run(['kubectl', 'get', 'no', '-o', 'wide'])
        print("\nNamespaces:")
        subprocess.run(['kubectl', 'get', 'ns'])
        print("\nStorage Classes:")
        subprocess.run(['kubectl', 'get', 'sc'])
        print("\nPersistent Volumes:")
        subprocess.run(['kubectl', 'get', 'pv'])
        rest()
        

def rest():
    REST=8
    time.sleep(REST)
    while is_pause_flag():
        time.sleep(1)
    

def is_pause_flag():
    with pause_lock:
        return pause_flag

def set_pause_flag(value):
    with pause_lock:
        pause_flag = value

def pause():
    set_pause_flag(True)
    print("Paused. Press Enter to continue.")
    input()
    set_pause_flag(False)

def signal_handler(sig, frame): 
    sys.exit(0)

def listen_for_spacebar():
    print_to_log("Begin listening for spacebar")
    while True:
        if keyboard.is_pressed('space'):
            print_to_log("listener Spacebar pressed")
        input("Press Enter to pause...")
        print_to_log("listener Enter pressed")
        pause()
    log_file_path = os.path.join(os.path.dirname(__file__), 'watch-all-pods.log')
    with open(log_file_path, 'a') as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    try:
        listener_thread = threading.Thread(target=listen_for_spacebar, daemon=True)
        listener_thread.start()
    except Exception as e:
        print(f"Error creating listener thread: {e}")
        sys.exit(1)
    watch_pods()