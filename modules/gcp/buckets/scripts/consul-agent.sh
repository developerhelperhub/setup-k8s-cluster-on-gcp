#!/bin/bash
set -e

echo "Configuring the variables"

# Variables
CONSUL_VERSION="1.20.6"

NODE_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")

echo "NODE_NAME: $NODE_NAME"
echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"

# ------------------- Install Consul Agent -----------------------
echo "Installing Consul Agent..."

# --------------------------- Installl Dependencies of Consul server -----------------------
echo "Installing consul dependencies..."

# Install dependencies
apt-get update -y
apt-get install -y unzip curl

# Download and install Consul
curl -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip /tmp/consul.zip -d /tmp
mv /tmp/consul /usr/local/bin/consul
chmod +x /usr/local/bin/consul

echo "Installed consul dependencies!"

# Get private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# --------------------------- Downloadinng the master configuration from storage bucket -----------------------

echo "Downloading the consul master configuration..."

sudo -u ubuntu gsutil cp gs://$SECURE_BUCKET_NAME/consol/server-node/consol_env.sh /home/ubuntu/consol_env.sh

chown ubuntu:ubuntu /home/ubuntu/consol_env.sh
chmod +x /home/ubuntu/consol_env.sh

source /home/ubuntu/consol_env.sh

echo "CONSUL_SERVER_IP: $CONSUL_SERVER_IP"

# Create agent config
cat <<EOF | tee /etc/consul.d/agent-config.json
{
  "server": false,
  "datacenter": "dc1",
  "node_name": "$NODE_NAME",
  "bind_addr": "$PRIVATE_IP",
  "retry_join": ["$CONSUL_SERVER_IP"],
  "data_dir": "/opt/consul"
}
EOF

cat /etc/consul.d/agent-config.json

chown consul:consul /etc/consul.d/agent-config.json

# Create systemd service
cat <<EOF | tee /etc/systemd/system/consul.service
[Unit]
Description=Consul Server
After=network.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Configured consul!"

# --------------------------- Consul server starting -----------------------

echo "Starting consul agent..."
# Start Consul server
systemctl daemon-reload
systemctl enable consul
systemctl start consul

echo "Started consul agent"

echo "Consul agent installed and running at $PRIVATE_IP!"