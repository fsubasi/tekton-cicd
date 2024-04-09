# tekton-task
Repo shows a sample of a Tekton Pipeline that performs the actions below.

- Fetch the repo.
- Compile the Go application.
- Run a basic unit test.
- Prepare an image tag.
- Build and Push image to the registry via Kaniko.
- Scan files and image with Trivy.
- Deploy the Kubernets manifests via Helm.

Pre-requisites:

- Kubernetes Cluster(Minikube in our case)

- Install Tekton Piplines[https://tekton.dev/docs/installation/pipelines/#installation]

- Install Tekton Triggers [https://tekton.dev/docs/installation/triggers/#installation]

- Optional: Install Tekton Dashboard[https://github.com/tektoncd/dashboard] 

- Optional: Tekton cli [https://tekton.dev/docs/cli/#installation]  


Steps:

- Create and configure a minikube cluster by applying the following commands.
 
  `brew install minikube` (edit this command if you are using a different OS)
  
  `minikube start`

  `kubectl create rolebinding admin \
  --clusterrole admin \
  --serviceaccount default:default`

- Apply Tasks Required from TektonHub

  1 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.4/git-clone.yaml`

  2 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/trivy-scanner/0.2/trivy-scanner.yaml`

  3 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.4/kaniko.yaml`

  4 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/golang-build/0.3/golang-build.yaml`

  5 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/golang-test/0.2/golang-test.yaml`

  You can apply them via tekton cli as well.

  1 `tkn hub install task git-clone`

  2 `tkn hub install task golang-build`

  3 `tkn hub install task golang-test`

  4 `tkn hub install task kaniko`

  5 `tkn hub install task trivy-scanner`

- Clone this Repo and Apply the Required Files
  
  1 `git clone https://github.com/fsubasi/tekton-cicd.git`

  2 `cd /tekton`

  3 `kubectl apply -f ./helm-upgrade.yaml`

  4 `kubectl apply -f ./pipeline.yaml`

  5 `kubectl apply -f ./pipelinerun.yaml`

  6 `kubectl apply -f ./trigger-binding.yaml`

  7 `kubectl apply -f ./trigger-template.yaml`

  8 `kubectl apply -f ./event-listener.yaml`

  9 `kubectl apply -f ./rbac-for-trigger/rbac.yaml`



#Notes

Sometimes ngrok dns might be changed if you are using the free version. At this time, you need to update the payload url of the github webhook with the new dns.

