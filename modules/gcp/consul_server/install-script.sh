#!/bin/bash
set -e

echo "Installing Consul server..."

# Variables
CONSUL_VERSION="1.20.6"

NODE_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")

echo "NODE_NAME: $NODE_NAME"
echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"

echo "Configured variables!"

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

# --------------------------- Consul server configuration -----------------------

echo "Configuring agent consul..."

# Create Consul user and directories
useradd --system --home /etc/consul.d --shell /bin/false consul || true
mkdir --parents /opt/consul
mkdir --parents /etc/consul.d
chown --recursive consul:consul /opt/consul /etc/consul.d

# Get private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Create server config
cat <<EOF | tee /etc/consul.d/server-config.json
{
  "server": true,
  "bootstrap_expect": 1,
  "datacenter": "dc1",
  "node_name": "$NODE_NAME",
  "bind_addr": "$PRIVATE_IP",
  "retry_join": [],
  "data_dir": "/opt/consul",
  "ui": true
}
EOF

cat /etc/consul.d/server-config.json

chown consul:consul /etc/consul.d/server-config.json

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

echo "Starting consul..."
# Start Consul server
systemctl daemon-reload
systemctl enable consul
systemctl start consul

echo "Started consul"

echo "Consul server installed and running at $PRIVATE_IP!"

# --------------------------- Upload the master configuration into storage bucket -----------------------

echo "Uploading master information into bucket..."

cat <<EOF | tee /home/ubuntu/consol_env.sh

export CONSUL_SERVER_IP="$PRIVATE_IP"

EOF

chown ubuntu:ubuntu /home/ubuntu/consol_env.sh
chmod +x /home/ubuntu/consol_env.sh

echo "Generated master information!"

echo "Uploading master informationn into bucket..."

sudo -u ubuntu gsutil cp /home/ubuntu/consol_env.sh gs://$SECURE_BUCKET_NAME/consol/server-node/consol_env.sh

echo "Uploaded master information into bucket!"

echo "***************Started Consul Server!***************"