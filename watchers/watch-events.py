#!/opt/homebrew/bin/python3

import subprocess
import time

def run_kubectl():
    while True:
        try:
            subprocess.run(['kubectl', 'get', 'events', '-A', '-w'], check=True)
        except subprocess.CalledProcessError:
            print("kubectl command failed, restarting...")
            time.sleep(1)  # Wait for a second before restarting

if __name__ == "__main__":
    run_kubectl()