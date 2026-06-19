#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    apt update && \
    apt install -y git

    wget https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
    tar -xzf helm-v3.8.0-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/
    rm -rf helm-v3.8.0-linux-amd64.tar.gz linux-amd64

    su admin -c "helm plugin install https://github.com/databus23/helm-diff"

    wget https://github.com/roboll/helmfile/releases/download/${helmfile_version}/helmfile_linux_amd64
    mv helmfile_linux_amd64 /usr/local/bin/helmfile
    chmod +x /usr/local/bin/helmfile

    curl -LO https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl
    mv kubectl /usr/local/bin/
    chmod +x /usr/local/bin/kubectl

    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
    mv aws-iam-authenticator /usr/local/bin/
    chmod +x /usr/local/bin/aws-iam-authenticator
    
    ##install docker
    curl -sSL https://get.docker.com | sh

    ##install docker-compose
    COMPOSE_VERSION="2.17.2"
    sudo curl -L https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose