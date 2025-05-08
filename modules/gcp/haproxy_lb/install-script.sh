#!/bin/bash
set -e


echo "Configured Variables"

SECURE_BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/SECURE_BUCKET_NAME" -H "Metadata-Flavor: Google")
FRONTEND_CONNECT_PORT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/FRONTEND_CONNECT_PORT" -H "Metadata-Flavor: Google")
FRONTEND_CONNECT_PROTOCOL=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/FRONTEND_CONNECT_PROTOCOL" -H "Metadata-Flavor: Google")
BACKEND_CONNECT_PROTOCOL=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_CONNECT_PROTOCOL" -H "Metadata-Flavor: Google")

echo "SECURE_BUCKET_NAME: $SECURE_BUCKET_NAME"
echo "FRONTEND_CONNECT_PORT: $FRONTEND_CONNECT_PORT"
echo "FRONTEND_CONNECT_PROTOCOL: $FRONTEND_CONNECT_PROTOCOL"
echo "BACKEND_CONNECT_PROTOCOL: $BACKEND_CONNECT_PROTOCOL"


# ------------------- Install consul agent commands  -----------------------
echo "Downloading the consul agent configuration..."

sudo -u ubuntu gsutil cp gs://$SECURE_BUCKET_NAME/consol/agent-node/consul-agent.sh /home/ubuntu/consul-agent.sh

echo "Installing Haproxy consul agent ..."
chmod +x /home/ubuntu/consul-agent.sh

# --------------------------- Consul server configuration -----------------------
echo "Configuring Haproxy consul agent..."

# Create Consul user and directories
useradd --system --home /etc/consul.d --shell /bin/false consul || true
mkdir --parents /opt/consul
mkdir --parents /etc/consul.d
chown --recursive consul:consul /opt/consul /etc/consul.d

bash /home/ubuntu/consul-agent.sh 

echo "Installed Haproxy consul agent!"

# --------------------------- haproxy server configuration -----------------------
apt-get update
apt-get install -y haproxy
systemctl enable haproxy

echo "Installed HAPorxy Tool!"

echo "Configuring HAPorxy..."

echo "resolvers consul
  nameserver consul 127.0.0.1:8600
  accepted_payload_size 8192
  resolve_retries       3
  timeout retry         2s" >> /etc/haproxy/haproxy.cfg

echo "frontend http_front
        bind *:$FRONTEND_CONNECT_PORT
        mode $FRONTEND_CONNECT_PROTOCOL
        default_backend haproxy_ingress_backend" >> /etc/haproxy/haproxy.cfg

echo "backend haproxy_ingress_backend
    mode $BACKEND_CONNECT_PROTOCOL
    balance roundrobin
    server-template app 3 _k8s-worker-node._tcp.service.consul resolvers consul resolve-prefer ipv4 check maxconn 32" >> /etc/haproxy/haproxy.cfg

echo "Configured HAPorxy!"

systemctl restart haproxy

echo "Restarted HAPorxy!"


# ------------------- ***** -------------------

echo "***************Started HAPorxy***************!"