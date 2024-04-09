# tekton-task
Repo shows a sample of a Tekton Pipeline using Trivy to scan output image and infrastructure as Code Components. Pipline will build sample Python Code, Create a temporary Docker Registry(Simulate Staging Env), Push Image to Docker Registry, Scan the Image and Push it to a Production Repo.

Pre-requisites:

- Kubernetes Cluster(Minikube in our case)

- Install Tekton Piplines[https://tekton.dev/docs/installation/pipelines/#installation]

- Install Tekton Triggers [https://tekton.dev/docs/installation/triggers/#installation]

- Optional: Install Tekton Dashboard[https://github.com/tektoncd/dashboard] 

- Optional: Tekton cli [https://tekton.dev/docs/cli/#installation]  


Steps:

- Apply Tasks Required from TektonHub

  1 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.4/git-clone.yaml`

  2 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/trivy-scanner/0.2/trivy-scanner.yaml`

  3 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.4/kaniko.yaml`

  4 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/golang-build/0.3/golang-build.yaml`

  5 `kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/golang-test/0.2/golang-test.yaml`

- Clone this Repo and Apply the Local Tasks Required
  
  1 `git clone https://github.com/fsubasi/tekton-cicd.git`

  2 `cd /tekton`

  3 `kubectl apply -f ./cicd/tasks -n tekton-pipelines`

- Create Pipeline PVC and make sure it binds
  1 `kubectl apply -f ./cicd/pipeline-pvc.yaml -n tekton-pipelines`
