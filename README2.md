Auto Scale Github Action Runners using Kubernetes, Terraform, and docker

1. Create the infrastructure, we are going to create 2 VPC, ,igw, 4 subnets, nat, routes, eks cluster with IAM roles and a managed instance group using Terraform.

Clone the repository
    sudo apt install git
    
    git clone https://github.com/jamcarbon/GitHubRunners_AWS

    cd GitHubRunners_AWS

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    
    sudo apt-get update && sudo apt-get install terraform

    terraform init


Make sure you have already installed cert-manager before you install.

    # REPLACE "v0.22.0" with the version you wish to deploy
    kubectl apply -f https://github.com/actions-runner-controller/actions-runner-controller/releases/download/v0.22.0/actions-runner-controller.yaml

    kubectl create secret generic controller-manager \
        -n actions-runner-system \
        --from-literal=github_app_id=${189801} \
        --from-literal=github_app_installation_id=${24883070} \
        --from-file=github_app_private_key=${ghratpk.pem}

    kubectl create secret generic controller-manager \
        -n actions-runner-system \
        --from-literal=github_token=${GITHUB_TOKEN}