#!/bin/bash


# Install common packages
apt-get update
apt-get install -y gnupg software-properties-common net-tools build-essential unzip

# Install NeoVim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> /home/ubuntu/.bashrc


git clone https://github.com/NvChad/starter ~/.config/nvim

# Install Ansible 
apt install ansible -y

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
echo "alias k=kubectl" >> /home/ubuntu/.bashrc

# Install K9s
wget https://github.com/derailed/k9s/releases/download/v0.50.4/k9s_linux_amd64.deb
dpkg -i k9s_linux_amd64.deb
rm k9s_linux_amd64.deb

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list
apt update
apt install terraform -y
terraform -install-autocomplete
echo "alias tf=terraform" >> /home/ubuntu/.bashrc

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm -y

# Install RKE2 Server Node

mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml

cat > /etc/rancher/rke2/config.yaml <<EOF
write-kubeconfig-mode: "0644"
token: ${RKE2_TOKEN}
server: https://${RKE2_SERVER_IP}:9345
node-name: ${RKE2_NODE_NAME}
cni: cilium
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

mkdir -p /home/ubuntu/.kube
cp /etc/rancher/rke2/rke2.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 644 /home/ubuntu/.kube/config