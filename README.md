
# Overview
This section explains how to set up a Kubernetes (K8s) cluster on Google Cloud Platform (GCP) using Terraform. Instead of using GCP's managed Kubernetes service, we will install open-source Kubernetes manually inside virtual machines (VMs).

# Objective
In software and microservice architecture design, it is essential to consider the scalability, availability, and performance of the application. I am proposing the following design considerations when selecting Kubernetes as part of the software architecture:

- When the application requires high performance, availability, scalability, and security
- When greater control over and maintenance of the infrastructure is needed
- When the application architecture involves complex microservices
- When opting for open-source solutions (optional)

When Kubernetes may not be the right choice:
- If the application is small and can be supported by a cloud provider’s managed services, such as AWS ECS with Fargate (serverless technology)
- If the application does not require high throughput
- If the goal is to minimize IT operational costs and reduce infrastructure management responsibilities

In this setup, I considered the following points while building Kubernetes (K8s) on GCP:
- Terraform: Used to easily deploy, manage, and destroy the cluster infrastructure.
- HAProxy: Implemented an open-source load balancer instead of relying on GCP’s native load balancer. HAProxy provides high-performance load balancing.
- Consul: Implemented VM discovery to automatically register Kubernetes worker nodes with the HAProxy load balancer.
- GCP Auto Scaling and VM Health Checks: Set up an autoscaling group with TCP-based health checks to ensure the availability and reliability of virtual machines.
- GCP RBAC: Leveraged GCP’s Role-Based Access Control to simplify node joining, manage Kubernetes-related files in GCP Buckets, and associate service accounts with bucket roles and virtual machines.
- Minimal Permissions: As a best practice, configured minimal necessary roles for infrastructure components to enhance security.
- Firewall Rules: Define and control inbound (ingress) and outbound (egress) network traffic to secure communication between resources.
- Private VPC: Create a dedicated Virtual Private Cloud (VPC) to isolate and secure resources, avoiding use of the default VPC. Resources in the private VPC, such as VMs, do not require external IP addresses and are accessed via internal IPs.
- IAP (Identity-Aware Proxy) TCP Forwarding: Enable secure SSH access to virtual machines running in private subnets without exposing them to the public internet.
- Private Google Access: Allow resources in private subnets to access Google services (e.g., Cloud Storage) over internal IPs by enabling this option at the subnet level.
- Public and Private Subnets: Segregate application components and manage network traffic more securely by deploying resources into distinct public and private subnets.
- Impersonate Service Account: Set up a service account that can be impersonated, granting it the necessary permissions to create and manage resources in Google Cloud Platform (GCP).
    - Advantage: This approach enhances security by allowing controlled, auditable access without needing to share long-lived credentials. It also enables role-based delegation, allowing users or services to act with limited, predefined permissions.

## Network Archiecture
![](https://paper-attachments.dropboxusercontent.com/s_B7610969A29EDB6B21671813BD4D5E7516166B429392B1369C36C5ECA7171F19_1749921340761_GCP-K8s-Setup-Networking.drawio.png)

## Infrastructure Archiecture
![](https://paper-attachments.dropboxusercontent.com/s_B7610969A29EDB6B21671813BD4D5E7516166B429392B1369C36C5ECA7171F19_1749921349331_GCP-K8s-Setup-Worker+Node+Auto+Registry+with+HAProxy.drawio+2.png)

**Note:** This is not a production-ready architecture. In production environments, you should create your own VPCs, such as separate networks for Management and Production environments (for eg: following HIPAA-compliant recommended network architecture practices).

## Prerequisites
We have to setup the following tools and accounts

- Create GCP account [we can create free tier account]
- Install Terraform in your machine [Min Terraform v1.9.3]
- Install gcloud command line in your machine  

## Create the servie account and permission in GCP
1. Enable Identity and Access Management (IAM) API
    1. Navigate to "APIs & Services": In the left-hand navigation menu, click on APIs & Services.
    2. Go to the "Library": On the "APIs & Services" overview page, click on + ENABLE APIS AND SERVICES or select Library from the sub-menu on the left.
    3. Search for the IAM API: In the search bar, type "Identity and Access Management (IAM) API".
    4. Select the API: Click on the "Identity and Access Management (IAM) API" from the search results. You'll be taken to the API's overview page.
    5. Enable the API: On the API overview page, you will see an Enable button if the API is not already enabled for your project. Click this button.
2. Select the project
3. Select GCP->Service Account
    1. Click "Create service account"
    2. Give service account name is "terraform-deployer"
    3. Give service account id is "terraform-deployer"
    4. Give service descripton is "Terraform deployer for creating the resources and networking"
        1. Output will be Email Id : terraform-deployer@{project}-{project_id}.iam.gserviceaccount.com
4. Add grand for root user
    1. GCP->IAM 
    2. Click "Grand Access"
    3. Give new principle name "root@email.com"
    4. Assign Roles: Click “Select a role” dropdown.
        1. Common roles:
        2. Service Account Token Creator - Generating access tokens, Calling GCP services on behalf of the service account
        3. IAP Role
            1. IAP-secured Tunnel User - This is the essential role. It allows a user or service account to connect to resources (like Compute Engine VMs) through IAP's TCP forwarding feature.
            2. Compute OS Admin Login - (basic user access, no sudo)
            3. Compute OS Login - (admin access, with sudo)
5. Add grand for service account of terraform deployer of management to access shared service resources
    1. GCP->IAM 
    2. Click "Grand Access"
    3. Give new principle name "terraform-deployer@{project}-{project_id}.iam.gserviceaccount.com"
    4. Assign Roles: Click “Select a role” dropdown.
        1. Common roles:
        2. Viewer – for read-only access
        3. Editor – for general write access
        4. Service Account Admin – for service account admin access
        5. Compute Network Admin – for networking admin access
        6. Compute Security Admin – for security admin access
        7. Service Account Token Creator - Generating access tokens, Calling GCP services on behalf of the service account
        8. Compute Instance Admin (v1) - for create instance

## Login GCP account
Login the GCP account through gcloud CLI command. Execute following command
```shell
gcloud auth login 
```

Create the configuration gcloud to separate/isolate the configuration for the project 
```shell
gcloud config configurations create devops-k8s
gcloud config configurations activate devops-k8s
```

Authenticate for a Specific Project To log in and set a GCP project:
```shell
gcloud config set project <PROJECT_ID>  --configuration=devops-k8s
```
Replace `GCP PROJECT_ID` with your actual project.

**Note**: Please follow the procedure if we are facing quota issues
```shell
* WARNING: Your active project does not match the quota project in your local Application Default Credentials file. This might result in unexpected quota issues.
* Update the quota project associated with ADC:

gcloud auth application-default set-quota-project <PROJECT_ID> 
gcloud config set project <PROJECT_ID> --configuration=devops-k8s
#If we are using env variable CLOUDSDK_CORE_PROJECT in .bash_profile, need to unset
unset CLOUDSDK_CORE_PROJECT
gcloud auth login --configuration=devops-k8s
```

### Configure the `env` variables
Following environment variables need to configure.
- `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT`: This variable configure the impersonate service account 
- `TF_VAR_gcp_project_id`: This variable to configure the GCP project id to use the terraform
```shell
vi ~/.bash_profile
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=terraform-deployer@{project}-{project_id}.iam.gserviceaccount.com
export set TF_VAR_terrafor_impersonate_service_account=terraform-deployer@{project}-{project_id}.iam.gserviceaccount.com
export set TF_VAR_gcp_project_id={your-gcp-project-id}
source ~/.bash_profile
```

### Create the Terraform workspace
The following command is used to create a Terraform workspace. A workspace in Terraform functions similarly to managing different environments in software development, such as `dev` and `prod`. In this setup, the workspace helps differentiate resources for each environment within the same GCP project.

We are following a consistent naming convention for resource creation in the GCP account:
Naming Pattern: `{project-id}-{env}-{resource-name}`

#### Examples for the `dev` environment:
- `myp-dev-secure-bucket`
- `myp-dev-k8s-master-node`
- `myp-dev-k8s-worker-node-1`

#### Examples for the `prod` environment:
- `myp-prod-secure-bucket`
- `myp-prod-k8s-master-node`
- `myp-prod-k8s-worker-node-1`

**Note:** As a best practice, production workloads should be managed in a separate GCP project. This approach improves production performance, enhances security, and ensures complete isolation between development and production environments.
```shell
terraform workspace new dev
```

### Terraform Configuration
Resource configurations can be defined in a `dev.tfvars` variable file. Different variable files can be maintained for different environments (e.g., `dev.tfvars`, `prod.tfvars`).
For example, project-specific values such as the project ID and project name for each environment can be configured in these files.

For example: 
```shell
#--------------------- Development Project Configuration ---------------------
#Development Project configuration, this project configuration is used to maintain resources for this project. eg: project_id will be used to create the GCP resources
project_id   = "myp"
project_name = "My Project"
# --------------------- GCP Project and Regsion Configuration ---------------------
gcp_region = "us-east1"
gcp_zone   = "us-east1-b"
#--------------------- Network Configuration ---------------------
nw_network_name          = "default"
nw_subnet_public_address_range = "10.0.0.0/24"
nw_subnet_private_address_range = "10.0.1.0/24"
```

### Setup the resources in GCP 
Run the following Terraform command to create the resources in the GCP .
```shell
terraform init --upgrade
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```


## Setup and connect IAP TCP Forwarding
To establish an SSH tunnel using IAP TCP Forwarding, we use the following command. During the initial execution, a password will be generated for the SSH connection. This password should be securely stored, as it will be required for future SSH access to the VM through the IAP tunnel.
```shell
gcloud compute ssh <YOUR_PRIVATE_VM_NAME> \
    --zone=<YOUR_VM_ZONE> \
    --tunnel-through-iap

User-Pro:infra user$ gcloud compute ssh myp-dev-k8s-master-node --zone=us-east1-b --tunnel-through-iap
WARNING: The private SSH key file for gcloud does not exist.
WARNING: The public SSH key file for gcloud does not exist.
WARNING: You do not have an SSH key for gcloud.
WARNING: SSH keygen will be executed to generate a key.
This tool needs to create the directory [/Users/user/.ssh] before being able to generate SSH keys.
Do you want to continue (Y/n)?  Y
Generating public/private rsa key pair.
Enter passphrase for "/Users/user/.ssh/google_compute_engine" (empty for no passphrase): xxxxxxxx
```

## Service Verification
Ensure that the virtual machines (VMs) are properly created, linked, and connected. This step helps identify any issues during VM provisioning or while installing necessary services. The following Git repository contains detailed debugging notes and documentation: (Debug Notes)[https://github.com/developerhelperhub/setup-k8s-cluster-on-gcp/tree/main/debugs]

Key Verification Steps:
- Confirm VM creation and successful setup
- Validate storage configuration
- Check Consul installation and status
- Verify the Kubernetes master node
- Ensure HAProxy is properly configured and running

## Install Web Applications K8s cluster
We deployed `nginx-web` as a sample application on the Kubernetes worker nodes and accessed it through the HAProxy load balancer. As HAProxy is the chosen load balancer in our architecture, we configured an HAProxy Ingress Controller during the master node setup. This controller efficiently routes incoming traffic to the appropriate applications running within the pods.

### Install the HAProxy ingress controller into master VM in the GCP console

1. Login into ubuntu user and changed into home directory
```shell
gcloud compute ssh myp-dev-k8s-master-node --zone=us-east1-b --tunnel-through-iap
sudo su ubuntu
cd
```

2. Ensure nodes are joined with master nodes
```shell
kubectl get nodes

#Output
NAME                           STATUS   ROLES           AGE     VERSION
myp-dev-k8s-master-node        Ready    control-plane   6m50s   v1.32.4
myp-dev-k8s-worker-node-0q3j   Ready    <none>          5m26s   v1.32.4
myp-dev-k8s-worker-node-c3js   Ready    <none>          5m28s   v1.32.4
```

3. Ensure HAProxy pods running properly in all worker nodes
```shell
kubectl get pods -n haproxy-controller -o wide

#Output
NAME                                        READY   STATUS      RESTARTS   AGE     IP                NODE                           NOMINATED NODE   READINESS GATES
haproxy-kubernetes-ingress-27lwj            1/1     Running     0          5m27s   192.168.100.1     myp-dev-k8s-worker-node-c3js   <none>           <none>
haproxy-kubernetes-ingress-crdjob-1-5rwd4   0/1     Completed   0          6m25s   192.168.100.2     myp-dev-k8s-worker-node-c3js   <none>           <none>
haproxy-kubernetes-ingress-khrxt            1/1     Running     0          4m56s   192.168.209.129   myp-dev-k8s-worker-node-0q3j   <none>           <none>
```

4. Ensure HAProxy service running properly in 30080 port
```shell
#Verify the service
kubectl get svc -n haproxy-controller haproxy-kubernetes-ingress

#Output
NAME                         TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                   AGE
haproxy-kubernetes-ingress   NodePort   10.97.64.228   <none>        80:30080/TCP,443:30443/TCP,443:30443/UDP,1024:30002/TCP   7m35s
```

5. Ensure Kube-proxy is Running Properly If HAProxy is running on the worker node, but the port is not open, it could be due to issues with kube-proxy, which manages the network routing for services in Kubernetes. Check if kube-proxy is running on the worker nodes:
```shell
kubectl get pods -n kube-system -o wide | grep kube-proxy

#Output
kube-proxy-9hqbv                                  1/1     Running   0          7m15s   10.0.1.4          myp-dev-k8s-worker-node-c3js   <none>           <none>
kube-proxy-cnlbl                                  1/1     Running   0          8m29s   10.0.1.3          myp-dev-k8s-master-node        <none>           <none>
kube-proxy-jrh2p                                  1/1     Running   0          7m13s   10.0.1.5          myp-dev-k8s-worker-node-0q3j   <none>           <none>
```

### Install sample nginx server in the K8s and create ingress resource of HAProxy

1. Install `nginx-web` server on K8s and expose `80` port
```shell
kubectl create deployment nginx-web --image=nginx --port=80
kubectl get deployments.apps -o wide
kubectl expose deployment nginx-web --port=80 --target-port=80 --type=ClusterIP
kubectl get  svc

#Output
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   60m
nginx-web    ClusterIP   10.110.173.152   <none>        80/TCP    16m
```

2. To Actually Spread Pods Across Multiple Nodes
```shell
kubectl scale deployment nginx-web --replicas=2
kubectl get pods -o wide -l app=nginx-web

Output:

NAME                         READY   STATUS    RESTARTS   AGE   IP                NODE                           NOMINATED NODE   READINESS GATES
nginx-web-8684b95849-j59tv   1/1     Running   0          11s   192.168.209.130   myp-dev-k8s-worker-node-0q3j   <none>           <none>
nginx-web-8684b95849-wn224   1/1     Running   0          32s   192.168.100.3     myp-dev-k8s-worker-node-c3js   <none>           <none>
```

3. Create the ingress resource to rout the request into `nginx-web:80` application
```shell
#Install VI editor to create the resource file
sudo apt install vim -y
vi nginx-ingress.yaml

#Copy following configuration insuide `nginx-ingress.yaml`
#nginx-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: default
  annotations:
    ingress.class: "haproxy"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-web
            port:
              number: 80
```

4. Apply the ingress resource
```shell
kubectl apply -f nginx-ingress.yaml
```

5. Identify the worker node Ip and test access of app through Node Port of worker node
```shell
kubectl get nodes -o wide
curl http://<worker-node1-ip>:30080
curl http://<worker-node2-ip>:30080
```

We will see following output of Nginx server home page
```html
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

6. Identify the `haporxay` external Ip address from GCP console and execute following command on browser
```shell
http://<haproxy-vm-external-ip>
```

## Destroy the resources in GCP account
Execute following commands to destroy / clean the resources which are created on GCP
```shell
terraform destroy -var-file="dev.tfvars"
```
