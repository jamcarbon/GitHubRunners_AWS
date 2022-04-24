# Auto-Scaling Github Action self-hosted Runners in AWS using Kubernetes and Terraform.

This controller operates self-husted runners for GitHub ACtions on your Kubernetes cluster.
Its going to upscale and downscale EC2 instances and pods depending on the pending jobs from GitHub actions, and push events.
For this test I use this repo for running the actions https://github.com/jamcarbon/test-rust, for each push event, 6 jobs will be generated.
When a push event is registered, API Gateway will activate a Lambda function which will increase the Elastic Kubernets Service desired capacity into 3, and 6 pods will be created. (1 for each job).
Cloudwatch will monitor the CPU usage and when it has been less than 5% usage for 10, it will decrease the desired capacity by 3, making the deployment to $0, to avoid paying when we don't need instances running.
If a 2nd push is send while the first push actions haven't finished, 3 more EC2 instances will be created, and after the first push actions will finish, a second cloudwatch rule will decreased the instances by 3 when the CPU usage is less than 60% among all the cluster.

Resources to be used:
AWS
Terraform
AWS API Gateway
AWS Lambda
AWS Elastic Kubernetes Service
AWS EC2
AWS Cloudwatch
Repositories used:
https://github.com/actions-runner-controller/actions-runner-controller

First, we need to create the infrastructure, we are going to terraform to deply all the infrastructure including the IAM roles.

Configure AWS (on your local pc)

    sudo apt install awscli

    aws configure

Clone the repository 

    sudo apt install git
    
    git clone https://github.com/jamcarbon/GitHubRunners_AWS

    cd GitHubRunners_AWS

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

Install terraform 

    sudo apt-get update && sudo apt-get install terraform

    cd terraform

Start Terraform

    terraform init

You can validate the terraform files by running

    terraform validate

You can check the terraform plan by running

    terraform plan

Deploy all the infrasctructure

    terraform apply

(To destroy all the infrastucture created)

    terraform apply -destroy

# Get the API Endpoint and attach it to GitHub Webhook

Run getAPI.py to get the API endpoint URL and then, go to your actions repo, settings, Webhook, Add webhook, paste the URL that you will get after running the below command, and "Add webhook".

    python3 getAPI.py



# Register Kubernetets to use AWS infrastructure    

    aws eks --region us-east-1 update-kubeconfig --name Runners

Test connection

    kubectl get svc

# Install cert-manager

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

Create namespace actions

    kubectl create ns actions

Go to your GitHub account and create an app, please follow the instructions on the wesite below to create an GitHub app and modify the values on the snip after this:
https://github.com/actions-runner-controller/actions-runner-controller#deploying-using-github-app-authentication

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
        --version 0.14.0 \     #change the version if required
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

# Wait 5 minutes and commit changes on the repository that the runners are configured to run, to test the runners, and go to actions tab on the repo

Check the logs of the desired instances

    kubectl logs -f [k8s-runners-name] -n actions runner

    kubectl logs -f [runner-actions-runner-controller-name] -n actions manager


# Get the current running intances with python

Run the python file to check for how many instances are running, their type, ID and the aproximate cost per hour.

Install dependencies first

    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update
    apt list | grep python3.9
    sudo apt-get install python3.9
    pip3 install boto3

    python get_ec2.py