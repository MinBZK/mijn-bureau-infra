#!/usr/bin/env bash

# This script create a kind cluster with nginx ingress controller and self-signed certificate for local testing.
# Usage: $0 [-d] [-k domain]
#   -d: delete the kind cluster after creation
#   -k: domain for the self-signed certificate (default: kubernetes.local

# Default values
CLUSTERNAME="mijnbureau"
HOMEIP=""

# Parse options
while getopts "c:d:" opt; do
  case $opt in
    c)
      CLUSTERNAME="$OPTARG"
      ;;
    d)
      HOMEIP="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-c name]"
      exit 1
      ;;
  esac
done

# Check if kind is installed
if ! command -v kind &> /dev/null; then
  echo "kind could not be found. Please install it. For more information visit https://kind.sigs.k8s.io/docs/user/quick-start/"
  exit 1
fi

# Check if Helmfile is installed
if ! command -v kubectl &> /dev/null; then
  echo "kubectl could not be found. Please install it. For more information visit https://kubernetes.io/docs/tasks/tools/"
  exit 1
fi

# Check if Helmfile is installed
if ! command -v mkcert &> /dev/null; then
  echo "mkcert could not be found. Please install it. for more information visit https://github.com/FiloSottile/mkcert"
  exit 1
fi

# Check if Helmfile is installed
if ! command -v docker &> /dev/null; then
  echo "docker could not be found. Please install it. for more information visit https://docs.docker.com/engine/install/"
  exit 1
fi

echo "0. Creating certificats"
mkcert -install > /dev/null 2>&1
if [ -z "$DOMAIN" ]; then
mkcert -install "127.0.0.1.sslip.io" "*.127.0.0.1.sslip.io" > /dev/null 2>&1
else
mkcert -install "127.0.0.1.sslip.io" "*.127.0.0.1.sslip.io" "*.${HOMEIP}.sslip.io"  > /dev/null 2>&1
fi

echo "1. Create registry container unless it already exists"
reg_name='kind-registry'
reg_port='5001'
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --network bridge --name "${reg_name}" \
    registry:3
fi

echo "2. Creating kind cluster ..."
if ! kind get clusters | grep ${CLUSTERNAME}; then
  cat <<EOF | kind create cluster --name ${CLUSTERNAME} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
nodes:
- role: control-plane
  image: kindest/node:v1.34.0
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30001
    hostPort: 30001
EOF
fi

if ! kubectl cluster-info --context kind-${CLUSTERNAME} > /dev/null 2>&1; then
  printf -- "${RED}FAILED: Error switching to kind cluster"
  exit 1
fi

echo "3. Add the registry config to the nodes in the kind cluster"
REGISTRY_DIR="/etc/containerd/certs.d/localhost:${reg_port}"
for node in $(kind get nodes --name ${CLUSTERNAME}); do
  docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
  cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
[host."http://${reg_name}:5000"]
EOF
done

echo "4. Connect the registry to the cluster network if not already connected"
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  docker network connect "kind" "${reg_name}"
fi

echo "5. Document the local registry"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
          ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        rewrite stop {
          name regex (.*).127.0.0.1.sslip.io ingress-nginx-controller.ingress-nginx.svc.cluster.local answer auto
        }
        cache 30
        loop
        reload
        loadbalance
    }
EOF

kubectl -n kube-system scale deployment coredns --replicas=1
kubectl -n kube-system rollout restart deployments/coredns

echo "5. Install nginx ingress controller"
if ! kubectl get ns ingress-nginx; then
  echo "Installing NGINX Ingress Controller..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.2/deploy/static/provider/kind/deploy.yaml > /dev/null 2>&1
  kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/docs/examples/customization/custom-errors/custom-default-backend.yaml > /dev/null 2>&1
  kubectl -n ingress-nginx create secret tls mkcert --key ${PWD}/127.0.0.1.sslip.io+1-key.pem --cert ${PWD}/127.0.0.1.sslip.io+1.pem|| echo ok
  kubectl -n ingress-nginx patch deployments.apps ingress-nginx-controller --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--default-ssl-certificate=ingress-nginx/mkcert"},{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--default-backend-service=ingress-nginx/nginx-errors"}
]'
  kubectl patch ingressclass nginx -p '{"metadata": {"annotations":{"ingressclass.kubernetes.io/is-default-class":"true"}}}'

  cat <<EOF | kubectl apply -n ingress-nginx -f -
  apiVersion: v1
  data:
    allow-snippet-annotations: "true"
    annotations-risk-level: Critical
    custom-http-errors: 500,501,502,503,504
  kind: ConfigMap
  metadata:
    name: ingress-nginx-controller
    namespace: ingress-nginx
EOF
fi

exit 1

# change configmap for ingress nginx
# kubectl patch configmap ingress-nginx-controller -n ingress-nginx --type merge -p '{"data": {"force-ssl-redirect": "true"}}' > /dev/null 2>&1


# change deployment to add default certificate
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--default-ssl-certificate=ingress-nginx/kind-tls"}]' > /dev/null 2>&1

# install gateway API
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

echo "Kind cluster ready for use, Execute the following command to install MijnBureau:"
echo "helmfile -e demo apply --skip-refresh"

echo "To autocreate namespace run:"
echo "export MIJNBUREAU_CREATE_NAMESPACES=true"
