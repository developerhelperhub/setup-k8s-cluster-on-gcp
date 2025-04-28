#!/bin/bash
apt-get update

apt-get install -y haproxy
systemctl enable haproxy

echo "Installed HAPorxy!"

FRONTEND_CONNECT_PORT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/FRONTEND_CONNECT_PORT" -H "Metadata-Flavor: Google")
FRONTEND_CONNECT_PROTOCOL=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/FRONTEND_CONNECT_PROTOCOL" -H "Metadata-Flavor: Google")
BACKEND_CONNECT_PROTOCOL=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_CONNECT_PROTOCOL" -H "Metadata-Flavor: Google")
BACKEND_K8S_WORKER_IPS=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_K8S_WORKER_IPS" -H "Metadata-Flavor: Google")
BACKEND_K8S_WORKER_PORT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_K8S_WORKER_PORT" -H "Metadata-Flavor: Google")

echo "FRONTEND_CONNECT_PORT: $FRONTEND_CONNECT_PORT"
echo "FRONTEND_CONNECT_PROTOCOL: $FRONTEND_CONNECT_PROTOCOL"
echo "BACKEND_CONNECT_PROTOCOL: $BACKEND_CONNECT_PROTOCOL"
echo "BACKEND_K8S_WORKER_IPS: $BACKEND_K8S_WORKER_IPS"
echo "BACKEND_K8S_WORKER_PORT: $BACKEND_K8S_WORKER_PORT"

echo "Configuring HAPorxy..."
echo "frontend http_front
        bind *:$FRONTEND_CONNECT_PORT
        mode $FRONTEND_CONNECT_PROTOCOL
        default_backend haproxy_ingress_backend" >> /etc/haproxy/haproxy.cfg

echo "backend haproxy_ingress_backend
    mode $BACKEND_CONNECT_PROTOCOL
    balance roundrobin
    server k8s-node1 $BACKEND_K8S_WORKER_IPS:$BACKEND_K8S_WORKER_PORT check maxconn 32" >> /etc/haproxy/haproxy.cfg

echo "Configured HAPorxy!"

systemctl restart haproxy

echo "Restart HAPorxy!"