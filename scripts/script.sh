
#!/bin/bash
set -e

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

install_kubectl() {
    log "Installing Kubectl..."
    curl -Lo kubectl https://dl.k8s.io/release/$(curl -s -L https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl || error_exit "Failed to download Kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl || error_exit "Failed to move Kubectl"
    log "Kubectl installed successfully"
}

create_user() {
    local USERNAME="$1"
    local PUB_KEY="$2"
    log "Creating user $USERNAME..."
    sudo useradd -m -s /bin/bash -G sudo "$USERNAME" || error_exit "Failed to create user $USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME || error_exit "Failed to set sudo privileges"
    sudo mkdir -p /home/$USERNAME/.ssh || error_exit "Failed to create .ssh directory"
    echo "$PUB_KEY" | sudo tee /home/$USERNAME/.ssh/authorized_keys || error_exit "Failed to update authorized_keys"
    sudo chmod 700 /home/$USERNAME/.ssh || error_exit "Failed to set .ssh directory permissions"
    sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys || error_exit "Failed to set authorized_keys permissions"
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh || error_exit "Failed to set ownership"
    log "User $USERNAME created successfully"
}

install_docker() {
    log "Installing Docker..."
    sudo apt-get -y update || error_exit "Failed to update package lists"
    sudo apt-get install -y ca-certificates curl || error_exit "Failed to install dependencies"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || error_exit "Failed to add Docker GPG key"
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get -y update || error_exit "Failed to update package lists after adding Docker repository"
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error_exit "Failed to install Docker"
    log "Docker installed successfully"
}

install_postgresql_client() {
    log "Installing PostgreSQL client..."
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /usr/share/keyrings/postgresql-key.asc > /dev/null || error_exit "Failed to add PostgreSQL GPG key"
    echo "deb [signed-by=/usr/share/keyrings/postgresql-key.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list || error_exit "Failed to add PostgreSQL repository"
    sudo apt update || error_exit "Failed to update package lists"
    sudo apt install -y postgresql-client-15 || error_exit "Failed to install PostgreSQL client"
    log "PostgreSQL client installed successfully"
}
install_mysql_client() {
    sudo apt-get install -y wget lsb-release gnupg debconf-utils
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client || error_exit "Failed to install Mysql client"


}

install_nfs_client() {
    local USERNAME="$2"
    local EFS_DNS="$1"
    sudo apt-get update -y
    sudo apt-get install nfs-common -y || error_exit "Failed to install NFS client"
    sudo mkdir -p mount-efs
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS:/ mount-efs
    sudo chown -R $USERNAME.$USERNAME mount-efs

}

install_helm() {
    sudo apt install -y git

    wget https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
    tar -xzf helm-v3.8.0-linux-amd64.tar.gz
    sudo mv linux-amd64/helm /usr/local/bin/
    sudo rm -rf helm-v3.8.0-linux-amd64.tar.gz linux-amd64

    su admin -c "helm plugin install https://github.com/databus23/helm-diff"

    wget https://github.com/roboll/helmfile/releases/download/v0.143.0/helmfile_linux_amd64
    sudo mv helmfile_linux_amd64 /usr/local/bin/helmfile
    sudo chmod +x /usr/local/bin/helmfile

    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
    sudo mv aws-iam-authenticator /usr/local/bin/
    sudo chmod +x /usr/local/bin/aws-iam-authenticator
}

# Main execution
USERNAME="ovpn"
PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1Iu++4RVdYWbLYgzz2R7s2jj7NYSXcoCQ9vne52MVAdf/RVR4A16oGxYBQ7pXTxk29Us3mqTEm2z+ZMMpBXY7r0LXBGArZZ47EiKwU5YxhU0uIarcfP8HlO8XFC6aLKaaSet2Z+ddgxFfwFakhIsFEtQoI5Tr52FH3uBY5dmVzxbi4dsEVhlois1HYk9lE09uKBeYBkRCE4l61sWL2DTxo+dFb0HCgmlW/XrNN5A8EHfE4f+q1PDw4GDgDeIlonmBllwBsM8JQAg65B4puHb4xFm+l1QXTdGo2NrXYrg31LK3BeTpwmGPARfFFIlWna1jOgLO0bnIfEFfRTL3wV/QAaILdbqUXjhaU8FnRaTIlbuX3uRC71hI50/JOpd534yoOFHSUpsoQ21C6Fq0mSmyrq+8A0TM+L7B9YJCZb+UKuQDLg0HiZ6ZZtF3Z3mW5MrrQWnzlanRzUvO4f1+jkfNiKeGa1bfaRLC3jhPcYO5f+ziMsQwSaLCEfYprsx8/a8= karpaten-eks@cloudhero.io"
EFS_DNS=$1

install_kubectl
create_user "$USERNAME" "$PUB_KEY"
install_docker
install_postgresql_client 

install_nfs_client "$EFS_DNS" "$USERNAME"

log "Installation completed successfully!"
