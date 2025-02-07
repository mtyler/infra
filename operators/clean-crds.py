import argparse
import subprocess

def get_crds(ns, domain):
    result = subprocess.run(['kubectl', 'get', 'crd', '-n', ns], capture_output=True, text=True)
    crds = [line.split()[0] for line in result.stdout.splitlines() if domain in line]
    print(crds)
    return crds

def del_crd(ns, crd):
    subprocess.run(['kubectl', 'delete', '-n', ns, 'crd', crd])

def main(args):
    crds = get_crds(args.namespace, args.domain)
    for crd in crds:
        del_crd(args.namespace, crd)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Clean up CRDs in a specified namespace.')
    parser.add_argument('-n', '--namespace', required=True, help='The namespace to clean up CRDs from')
    parser.add_argument('-d', '--domain', required=True, help='The domain of CRDs to clean up. ie. ceph.rook.io')
    args = parser.parse_args()

    main(args)