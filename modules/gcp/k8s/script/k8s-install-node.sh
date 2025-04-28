#!/bin/bash
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

SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")

echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"

sudo -u ubuntu gsutil cp gs://$SECURE_BUCKET_NAME/k8s/master-node/join_node.sh /home/ubuntu/join_node.sh

echo "Joining the master node..."
chmod +x /home/ubuntu/join_node.sh 

bash /home/ubuntu/join_node.sh 

echo "Joined the master node successfully!"


