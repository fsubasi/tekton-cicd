#!/bin/bash
 
set -eE -o pipefail  # Exit immediately if a command exits with a non-zero status
 
# Install necessary packages using Homebrew
echo "=====Required binaries are being installed!====="
 
brew install kubectl minikube helm tektoncd-cli
 
# Start Minikube and configure environment
echo "=====Minikube is being started!====="
 
minikube start -p tekton --memory=4096 --cpus=2
 
sleep 15
 
#Give admin privilege to default user"
kubectl create rolebinding admin --clusterrole admin --serviceaccount default:default
 
#Create application namespace.
kubectl create namespace go-app
 
echo "=====docker creds are being created====="
 
read -p "Enter the path to your config.json file: " config_path
 
# Check if the file exists
if [ -f "$config_path" ]; then
    # Create the Kubernetes secret with the provided config.json file
    kubectl create secret generic dockerhub-creds --from-file=config.json="$config_path"
    echo "Secret created successfully."
else
    echo "Error: File not found at the specified path."
    exit 1
fi
 
 
# Install Tekton Pipelines
echo "=====Tekton pipeline resources are being applied====="

kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for all pods in tekton-pipelines namespace to be ready
echo "Waiting for all pods in tekton-pipelines namespace to be ready..."
while true; do
    all_ready="yes"
    for pod in $(kubectl get pods -n tekton-pipelines --no-headers=true | awk '{print $2}'); do
        if [[ "$pod" != "1/1" ]]; then
            all_ready="no"
            break
        fi
    done
    if [ "$all_ready" = "yes" ]; then
        echo "All pods are ready. Proceeding with installing tasks!"
        break
    else
        echo "Not all pods are ready yet. Waiting..."
        sleep 20
    fi
done

# Apply required tasks from tekton hub.

tkn hub install task git-clone
 
tkn hub install task golang-build
 
tkn hub install task golang-test
 
tkn hub install task kaniko
 
tkn hub install task trivy-scanner
 
sleep 10
 
# Create namespace, service account, role and rolebinding for helm deployment process.
 
echo "=====role and rolebindings are being applied for helm deployment====="
 
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: go-app
  name: helm-deploy-role
rules:
- apiGroups: [""]
  resources: ["secrets", "services", "pods", "deployments", "configmaps", "services/finalizers"]
  verbs: ["get", "list", "create", "update", "delete", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments", replicasets]
  verbs: ["get", "list", "create", "update", "delete", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: helm-deploy-role-binding
  namespace: go-app
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role
  name: helm-deploy-role
  apiGroup: rbac.authorization.k8s.io
EOF
 
echo "=====The repository is being cloned====="
 
echo "=====Cloning the repository if it doesn't exist====="

if [ ! -d "tekton-cicd" ]; then
    git clone https://github.com/fsubasi/tekton-cicd.git
    echo "Repository cloned successfully."
else
    echo "The repository directory 'tekton-cicd' already exists and is not an empty directory."
fi
 
# Apply Tekton resources
 
echo "=====tekton resources are being applied====="

cd tekton-cicd/tekton
 
kubectl apply -f ./helm-upgrade.yaml
 
kubectl apply -f ./pipeline.yaml
 
sleep 5
 
echo "====The process has been completed, running the first pipeline!====="
 
kubectl create -f ./pipelinerun.yaml
 
tkn pipelinerun logs --follow --last

echo "Waiting for app pod in go-app namespace to be ready..."
while true; do
    if kubectl get pods -n go-app | grep -q "1/1"; then
        echo "The pod is ready!"
        break
    else
        echo "The pod is not ready yet. Waiting..."
        sleep 10
    fi
done

echo "running the app on your browser!"

minikube service go -n go-app
 
# Optional cleanup
# minikube stop
# minikube delete