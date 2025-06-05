#!/bin/bash

# Install Worker Node
mkdir -p /etc/rancher/rke2
touch /etc/rancher/rke2/config.yaml
# Set configuration for RKE2 Agent
cat > /etc/rancher/rke2/config.yaml <<EOF
# RKE2 Agent Configuration
server: https://${RKE2_SERVER_IP}:9345
token: ${RKE2_TOKEN}
node-name: ${RKE2_NODE_NAME}
EOF

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service

# Start RKE2 Agent
systemctl enable rke2-agent.service
systemctl start rke2-agent.service
