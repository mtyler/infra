import os
import subprocess
proc = subprocess.Popen(['ls'], stdout=subprocess.PIPE)
print(proc.stdout.readlines())
# until I can discover a cleaner solution. 
# This script updates the kube-proxy configMap so that the service is
# discovered by prometheus

# leaving this sed command here for the time being
#    this command functions on MacOS. For linux, remove both single quotes after -i 
#    sed -i '' 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/g' $TEMP_FILE


TEMP_FILE='monkeypatch-kubeProxy'
FIND_TEXT='metricsBindAddress: ""'
REPL_TEXT='metricsBindAddress: 0.0.0.0:10249'
GET_CM=f'kubectl get configmaps -n kube-system kube-proxy -o yaml > {TEMP_FILE}' 
APPLY_CM=f'kubectl apply -f {TEMP_FILE}'
GET_PROXYS=f'kubectl get pods -n kube-system -l k8s-app=kube-proxy -o custom-columns=NAME:metadata.name --no-headers > {TEMP_FILE}'

os.system(GET_CM)
# Read in the file
with open(TEMP_FILE, 'r') as file:
  # replace text
  filedata = file.read().replace(FIND_TEXT, REPL_TEXT)

# Write the file out again
with open(TEMP_FILE, 'w') as file:
  file.write(filedata)

os.system(APPLY_CM)

# get the running kube-proxy
os.system(GET_PROXYS)
with open(TEMP_FILE, 'r') as file:
    for line in file:
        os.system(f'kubectl delete -n kube-system pod {line}')

os.system(f'rm -f {TEMP_FILE}')
