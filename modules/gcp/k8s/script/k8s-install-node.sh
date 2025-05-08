#!/bin/bash
set -e

echo "Configuring the variables"

SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")
K8S_NODE_CONNECT_PORT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/K8S_NODE_CONNECT_PORT" -H "Metadata-Flavor: Google")

echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"
echo "K8S_NODE_CONNECT_PORT: $K8S_NODE_CONNECT_PORT"

# ------------------- Install Dependencies K8s -----------------------
echo "Intalling dependencies of k8s ........"

# Update and install necessary dependencies for containers Container Referece Interface
apt update && sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Install Container GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install Kubernetes GPG key and repository
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet, kubeadm, kubectl, containerd
apt update && sudo apt install -y containerd.io kubelet kubeadm kubectl

echo "Intalled the tools!"

# Container configure default configuration
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml && sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

echo "Container configure default configuration!"

echo "Disabling swapoff"
# Disable swap (Kubernetes requirement)
swapoff -a
sed -i '/swap/d' /etc/fstab

echo "Enabiling IP forwarding"
# Enabling the IP forwarding
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

echo "Configured the paramters of VM for K8s!"

# ------------------- Run K8s admin join commands  -----------------------
echo "Downloading the k8s master configuration..."

sudo -u ubuntu gsutil cp gs://$SECURE_BUCKET_NAME/k8s/master-node/join_node.sh /home/ubuntu/join_node.sh

echo "Joining the master node..."
chmod +x /home/ubuntu/join_node.sh 

bash /home/ubuntu/join_node.sh 

echo "Joined the master node successfully!"

# ------------------- Install consul agent commands  -----------------------
echo "Downloading the consul agent configuration..."

sudo -u ubuntu gsutil cp gs://$SECURE_BUCKET_NAME/consol/agent-node/consul-agent.sh /home/ubuntu/consul-agent.sh

PRIVATE_IP=$(hostname -I | awk '{print $1}')

# --------------------------- Consul server configuration -----------------------
echo "Configuring K8s consul..."

# Create Consul user and directories
useradd --system --home /etc/consul.d --shell /bin/false consul || true
mkdir --parents /opt/consul
mkdir --parents /etc/consul.d
chown --recursive consul:consul /opt/consul /etc/consul.d

# Create agent config
cat <<EOF | tee /etc/consul.d/k8s-worker-node-config.json
{
  "service": {
    "name": "k8s-worker-node",
    "port": $K8S_NODE_CONNECT_PORT,
    "tags": ["k8s"],
    "check": {
      "tcp": "$PRIVATE_IP:$K8S_NODE_CONNECT_PORT",
      "interval": "5s"
    }
  }
}
EOF

cat /etc/consul.d/k8s-worker-node-config.json

chown consul:consul /etc/consul.d/k8s-worker-node-config.json

echo "Installing consul agent ..."

chmod +x /home/ubuntu/consul-agent.sh

bash /home/ubuntu/consul-agent.sh 

# ------------------- ***** -------------------
echo "***************Started K8s worker node!***************"


