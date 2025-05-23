#!/bin/bash
set -e

echo "Configuring the variables"

SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")

echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"

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

# Initialize the Kubernetes master node (only on master)
echo "Waiting for the control plane to be ready..."
until kubeadm init --pod-network-cidr=192.168.0.0/16 | grep "Your Kubernetes control-plane has initialized successfully!"; do
    echo "Waiting for the node to become 'Ready'..."
    sleep 5
done

echo "Kubernetes has initialized successfully!"

echo "HOME is set to: /home/ubuntu/.kube/config"
# Set up kubeconfig for root and regular user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Apply a network plugin (Calico in this case)
sudo -u ubuntu KUBECONFIG=/home/ubuntu/.kube/config kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "Installed all tools and services and ready K8s in the VM!"

echo "Generating token"

kubeadm token create --print-join-command > /home/ubuntu/join_node.sh

chown ubuntu:ubuntu /home/ubuntu/join_node.sh
chmod +x /home/ubuntu/join_node.sh

echo "Generated token!"

# ------------------- Run K8s admin join commands  -----------------------

echo "Uploading token into bucket..."

sudo -u ubuntu gsutil cp /home/ubuntu/join_node.sh gs://$SECURE_BUCKET_NAME/k8s/master-node/join_node.sh

echo "Uploaded token into bucket!"

# ------------------- K8s tools  -----------------------

echo "Installing k8s tools..."


echo "Installing Helm..."
# Install Helm
sudo curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
sudo echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo apt update
sudo apt install helm

echo "Instelled Helm!"

echo "Installing HAProxy Ingress Controller..."

# Install haproxy ingress controller
sudo -u ubuntu helm repo add haproxytech https://haproxytech.github.io/helm-charts
sudo -u ubuntu helm repo update

sudo -u ubuntu helm install haproxy-kubernetes-ingress haproxytech/kubernetes-ingress \
  --create-namespace \
  --namespace haproxy-controller \
  --set controller.kind=DaemonSet \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443 \
  --set controller.service.nodePorts.stat=30002 \
  --set controller.service.nodePorts.prometheus=30003

echo "Instelled HAProxy Ingress Controller!"

# ------------------- ***** -------------------
echo "***************Started K8s master node!***************"