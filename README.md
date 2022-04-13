# GitHubRunners_AWS
Cluster of GitHub Runners on AWS.

How to Create a Cluster of GitHub runners on AWS

1.	Select a proper AMI (Ubuntu server) and for instance type ARM Neoverse cores deliver the best price performance for cloud workloads, we can choose compute optimized (C6g, C6gdm C6gn) or memory optimized (R6g, R6gd, X2gd). These instances provide up to 40% better price performance over x86 instances. For example c6gd.medium  which has 1 core and 2 GB RAM with 60gb SSD, or m6g.large.
 

 


2.	Create the actions runners image

    #/home/ubuntu
    #sudo apt update -y
    #sudo apt install -y yum-utils
    #sudo yum update -y
    #sudo yum install jq, expect -y


Create a folder

    sudo apt update

    mkdir actions-runner && cd actions-runner# Download the latest runner package

    curl -o actions-runner-linux-x64-2.289.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.289.2/actions-runner-linux-x64-2.289.2.tar.gz# 

Optional: Validate the hash

    echo "7ba89bb75397896a76e98197633c087a9499d4c1db7603f21910e135b0d0a238  actions-runner-linux-x64-2.289.2.tar.gz" | shasum -a 256 -c# Extract the installer

    tar xzf ./actions-runner-linux-x64-2.289.2.tar.gz

Create the runner and start the configuration experience

    ./config.sh --url https://github.com/jamcarbon/test-rust --token ABNDEERGC6WPCF2BTP3CP3TCKI2VU# Last step, run it!
    ./run.sh

Use this YAML in your workflow file for each job

    runs-on: self-hosted


3. Add to the image the package requires for susbtrate development

    sudo apt update && sudo apt install -y git clang curl libssl-dev llvm libudev-dev

Install Rust and the rust toolchain

    curl https://sh.rustup.rs -sSf | sh
    source ~/.cargo/env
    rustup default stable
    rustup update
    rustup update nightly
    rustup target add wasm32-unknown-unknown --toolchain nightly
    rustc --version
    rustup show

Setup a Substrate developer environment for running the tests
(https://docs.substrate.io/tutorials/v3/create-your-first-substrate-chain/)

    git clone https://github.com/jamcarbon/test-rust

    cd test-rust

We want to use the `master` tag throughout all of this process

    git checkout master

    cp Cargo.dev.toml Cargo.toml

    cargo build --release






4.	

5.	
