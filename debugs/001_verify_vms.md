
# Verify the services are installed in the K8s VM and HAProxy VM

## SSH into Master VM in the GCP console
1. Connect VM throguh IAP tunnel
```shell
gcloud compute ssh myp-dev-k8s-master-node --zone=us-east1-b --tunnel-through-iap
```
2. Verify all initial script execute properly while start the VM
```shell
#For Google Cloud VM Instances:
#When using the metadata_startup_script in a GCP VM, the startup script output is logged to:
tail -500f /var/log/syslog
cat /var/log/syslog | grep "Intalled the tools!"
cat /var/log/syslog | grep "Container configure default configuration!"
cat /var/log/syslog | grep "Enabiling IP forwarding"
cat /var/log/syslog | grep "Configured the paramters of VM for K8s!"
cat /var/log/syslog | grep "Kubernetes has initialized successfully!"
cat /var/log/syslog | grep "Uploaded token into bucket!"

cat /var/log/syslog | grep "Instelled Helm!"
cat /var/log/syslog | grep "Instelled HAProxy Ingress Controller!"
cat /var/log/syslog | grep "Started K8s master node!"

grep -B 2 -A 50 "Waiting for the control plane to be ready..." /var/log/syslog
```

## SSH into Worker VM in the GCP console
1. Connect VM throguh IAP tunnel
```shell
gcloud compute ssh myp-dev-k8s-worker-node-lfnc --zone=us-east1-b --tunnel-through-iap
```
2. Verify all initial script execute properly while start the VM
```shell
#For Google Cloud VM Instances:
#When using the metadata_startup_script in a GCP VM, the startup script output is logged to:
tail -500f /var/log/syslog
cat /var/log/syslog | grep "Joined the master node successfully!"
```

## Verify the Bucket
1. Check in bucket storage whether the file is uploaded or not `/k8s/master-node/join_node.sh`

## SSH into Consul server in the GCP console
1. Connect VM throguh IAP tunnel
```shell
gcloud compute ssh myp-dev-consul-server-1 --zone=us-east1-b --tunnel-through-iap
```
2. Verify all initial script execute properly while start the VM
```shell
#For Google Cloud VM Instances:
#When using the metadata_startup_script in a GCP VM, the startup script output is logged to:
tail -500f /var/log/syslog
cat /var/log/syslog | grep "Configured consul!"
cat /var/log/syslog | grep "Uploading master informationn into bucket..."
cat /var/log/syslog | grep "Uploaded master information into bucket!"
cat /var/log/syslog | grep "Started Consul Server!"
```

## SSH into Consul agent [k8s worker node] in the GCP console
1. Connect VM throguh IAP tunnel
```shell
gcloud compute ssh myp-dev-consul-server-1 --zone=us-east1-b --tunnel-through-iap
```
2. Verify all initial script execute properly while start the VM
```shell
#For Google Cloud VM Instances:
#When using the metadata_startup_script in a GCP VM, the startup script output is logged to:
tail -500f /var/log/syslog
cat /var/log/syslog | grep "Joined the master node successfully!"
cat /var/log/syslog | grep "Downloading the consul agent configuration..."
cat /var/log/syslog | grep "Configuring K8s consul..."
cat /var/log/syslog | grep "Installing consul agent ..."
cat /var/log/syslog | grep "Installing Consul Agent..." -B10 -A20

ls /home/ubuntu/consul-agent.sh

# K8s worker node addition file created
ls /etc/consul.d/k8s-worker-node-config.json
cat /etc/consul.d/k8s-worker-node-config.json


cat /var/log/syslog | grep "Installed consul dependencies!" -B10 -A20
cat /var/log/syslog | grep "CONSUL_SERVER_IP" -B10 -A20

cat /var/log/syslog | grep "Configured consul!"
cat /var/log/syslog | grep "Starting consul agent..."
```

## SSH into HAProxy VM in the GCP console
1. Connect VM throguh IAP tunnel
```shell
gcloud compute ssh myp-dev-haproxy-lb-1 --zone=us-east1-b --tunnel-through-iap
```
2. Verify all initial script execute properly while start the VM
```shell
tail -500f /var/log/syslog

cat /var/log/syslog | grep "Downloading the consul agent configuration..."
cat /var/log/syslog | grep "Configuring Haproxy consul agent..."
cat /var/log/syslog | grep "Installing consul agent ..."
cat /var/log/syslog | grep "Installing Consul Agent..." -B10 -A20

ls /home/ubuntu/consul-agent.sh

cat /var/log/syslog | grep "Configuring consul..." -B10 -A20
cat /var/log/syslog | grep "CONSUL_SERVER_IP" -B10 -A20

cat /var/log/syslog | grep "Started consul agent"

cat /var/log/syslog | grep "Installed Haproxy consul agent!"
cat /var/log/syslog | grep "Installed HAPorxy Tool!"
cat /var/log/syslog | grep "Configuring HAPorxy..."
cat /var/log/syslog | grep "Configured HAPorxy!" -A10
cat /var/log/syslog | grep "Restarted HAPorxy!"
```


gcloud compute config-ssh: Sometimes, refreshing the gcloud SSH configuration helps:
```Bash
gcloud compute config-ssh
```
This command adds host entries for your instances to your ~/.ssh/config file, which can sometimes help with key management.

```shell
gcloud compute ssh myp-dev-haproxy-lb-1 --zone=us-east1-b --tunnel-through-iap --dry-run --debug
```