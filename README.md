# Auto Scale Github Action Runners using Kubernetes, Terraform, and docker

1. Create the infrastructure, we are going to create 2 VPC, ,igw, 4 subnets, nat, routes, eks cluster with IAM roles and a managed instance group using Terraform.

Configure AWS (on your local pc)

    sudo apt install awscli

    aws configure

Clone the repository 
    sudo apt install git
    
    git clone https://github.com/jamcarbon/GitHubRunners_AWS
    # git pull https://github.com/jamcarbon/GitHubRunners_AWS main

    cd GitHubRunners_AWS

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

    sudo apt-get update && sudo apt-get install terraform

    cd terraform

    terraform init

    terraform apply

    # terraform apply -destroy

    aws eks --region us-east-1 update-kubeconfig --name demo

Test connection

    kubectl get svc

Install cert-manager

    sudo snap install helm --classic

    helm repo add jetstack https://charts.jetstack.io

    helm repo update

    helm search repo cert-manager

Watch current pods

    watch kubectl get pods -A

    helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.6.0 \
    --set prometheus.enabled=false \
    --set installCRDs=true


  
# Installation of runners controller

Make sure you have already installed cert-manager before you install.

    kubectl create ns actions

    kubectl create secret generic controller-manager \
        -n actions \
        --from-literal=github_app_id=189801 \
        --from-literal=github_app_installation_id=24883070 \
        --from-file=github_app_private_key=ghratpk.pem

    helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

    helm repo update

    helm search repo actions

    helm install runner \
        actions-runner-controller/actions-runner-controller \
        --namespace actions \
        --version 0.14.0 \
        --set syncPeriod=1m

Let's check if the controller is up

    kubectl get pods -n actions

# Deploy runners

Validate .yaml

    kubeval k8s/runner-deployment.yaml

    kubectl apply -f k8s/runner-deployment.yaml -n actions

    kubectl apply -f k8s/runner-hzsc.yaml -n actions

    kubectl get pods -n actions

    kubectl logs -f runner-deployment1 -c runner -n actions

    # kubectl delete all --all

    

















    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

    kubectl get pods --namespace cert-manager

    REPLACE "v0.22.0" with the version you wish to deploy

    kubectl apply -f https://github.com/actions-runner-controller/actions-runner-controller/releases/download/v0.22.3/actions-runner-controller.yaml

    

    kubectl create secret generic controller-manager \
        -n actions-runner-system \
        --from-literal=github_token=${GITHUB_TOKEN}