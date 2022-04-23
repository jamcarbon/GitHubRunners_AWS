# Auto Scale Github Action Runners using Kubernetes, Terraform, and docker

Create the infrastructure, we are going to create 2 VPC, ,internet gate way, 4 subnets, nat, routes, eks cluster with IAM roles and a managed instance group using Terraform.

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

Validate the templates    

    terraform init

You can validate the terraform files by running

    terraform validate

You can check the terraform plan by running

    terraform plan

To apply all the infrastructure run    

    terraform apply

To destroy all the infrastucture created    

    terraform apply -destroy


# Register Kubernetets to use AWS infrastructure    

    aws eks --region us-east-1 update-kubeconfig --name Runners

Test connection

    kubectl get svc

Install cert-manager

    sudo snap install helm --classic

    helm repo add jetstack https://charts.jetstack.io

    helm repo update

    helm search repo cert-manager

Watch current pods

    watch kubectl get pods -A

Open a new command prompt    

Install cert-manager

    helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.6.0 \
    --set prometheus.enabled=false \
    --set installCRDs=true

  
# Installation of runners controller

Make sure you have already installed cert-manager before you install.

Create namespace actions

    kubectl create ns actions

Go to your GitHub account and create an app, please follow the instructions on the wesite below to create an GitHub app and modify the values on the snip after this:

    https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app

    kubectl create secret generic controller-manager \
        -n actions \
        --from-literal=github_app_id=[your_app_id] \
        --from-literal=github_app_installation_id=[installation_id] \
        --from-file=github_app_private_key=[your_key.pem]

    watch kubectl get pods --all-namespaces

    helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

    helm repo update

    helm search repo actions

    helm install runner \
        actions-runner-controller/actions-runner-controller \
        --namespace actions \
        --version 0.14.0 \
        --set syncPeriod=2m

Let's check if the controller is up

    kubectl get pods -n actions

# Deploy runners

Apply the deployment    

    kubectl apply -f k8s/runner-deployment.yaml

Apply the horizontal autoscaler    

    kubectl apply -f k8s/horizontal-runner-autoscaler.yaml

Check the generated pods 

    kubectl get pods -n actions

# Commit changes on the repository that the runners are configured to run, to test the runners, and go to actions tab on the repo

Check the logs of the desired instances

    kubectl logs -f k8s-runners-ncndz-77qr4 -n actions runner

    kubectl logs -f runner-actions-runner-controller-7db574bbf-4v9w6 -n actions manager



    # kubectl delete all --all


    # kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler
    

















    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

    kubectl get pods --namespace cert-manager

    REPLACE "v0.22.0" with the version you wish to deploy

    kubectl apply -f https://github.com/actions-runner-controller/actions-runner-controller/releases/download/v0.22.3/actions-runner-controller.yaml

    

    kubectl create secret generic controller-manager \
        -n actions-runner-system \
        --from-literal=github_token=${GITHUB_TOKEN}


kubectl exec --stdin --tty k8s-runners-lz6p5-6kqdj -- /bin/bash
