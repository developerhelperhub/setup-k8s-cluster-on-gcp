
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
- Firewall Rules: Configured the following rules: 
  - HAProxy 
    - Ingress rule
      - Port: 80
      - Public access of HAPRoxy endpoint
  - HAProxy → Kubernetes Worker Nodes (port 30080).
  - Consul rule 
    - Ingress and Egress
      - For all agents based on VM tag (HAProxy, K8s Worker Nodes)
      - Port: 8301, 8600, 8300 for Ingress and Egress rule
      - Private and public network
  - K8s Rule
    - For master node and all worker nodes based on VM tag 
      - Ingress 
        - Port: 10250, 30000-32767, 10255, 6443
        - Private network only
      - Egress
        - Port: 443, 6443
        - Private network only
    - For all worker nodes connecting to HProxy based on VM tag
      - Ingress 
        - Port: 30080
        - Public network only
      - Egress
        - Port: 30080
        - Private network only
    - Health Check API of GCP based on k8s nodes tag
      - Ingress 
        - Port: 10250
        - GCP Health check netowrk
- Public and Private Subnets: Separated application workloads and network traffic by isolating resources into public and private subnets.

![](https://paper-attachments.dropboxusercontent.com/s_B01A637F1BA6970A895150AACF9F97518302CD6FE74617377124E54312BFFC88_1746675239385_GCP-K8s-Setup-Worker+Node+Auto+Registry+with+HAProxy.drawio+1.png)

**Note:** This is not a production-ready architecture. In production environments, the default network should not be used. Instead, you should create your own VPCs, such as separate networks for Management, Development, and Production environments (for eg: following HIPAA-compliant recommended network architecture practices).

# Prerequisites
We have to setup the following tools and accounts

- Create GCP account [we can create free tier account]
- Install Terraform in your machine [Min Terraform v1.9.3]
- Install gcloud command line in your machine  

### Login GCP account

Login the GCP account through gcloud CLI command. Execute following command
```shell
gcloud auth login 
```

(Optional) Re-authenticate for a Specific Project
To log in and set a GCP project:
```shell
gcloud config set project PROJECT_ID
```
Replace `GCP PROJECT_ID` with your actual project.

### Configure the `env` variables
Following environment variables need to configure. Replace the GCP project id with `{your-gcp-project-id}`.

- `CLOUDSDK_CORE_PROJECT`: This variable configure the GCP project id to use the `gcloud` cli command
- `TF_VAR_gcp_project_id`: This variable to configure the GCP project id to use the terraform
```shell
export CLOUDSDK_CORE_PROJECT={your-gcp-project-id}
export set TF_VAR_gcp_project_id={your-gcp-project-id}
```

### Terraform Structure
Following the terraform module maintain to deploy the resources in the GCP account
![](https://paper-attachments.dropboxusercontent.com/s_B01A637F1BA6970A895150AACF9F97518302CD6FE74617377124E54312BFFC88_1746675257577_Screenshot+2025-05-08+at+9.02.07AM.png)

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

It creates the following resources in GCP project account
**Service Account:**
* myp-k8s-master-sa@xxxxxx.gserviceaccount.com
* myp-k8s-worker-sa@xxxxxx.gserviceaccount.com
* myp-consul-sa@xxxxxx.gserviceaccount.com
* myp-lb-haproxy-sa@xxxxxx.gserviceaccount.com
**VPC Network (default)→Subnet:**
* myp-dev-private-subnet
* myp-dev-public-subnet
**VPC Network (default)→Firewall:**
* myp-dev-consol-incoming-from-consol-server
* myp-dev-consol-outgoing-to-consol-server
* myp-dev-haproxy-lb-allow-http
* myp-dev-k8s-incoming-from-haproxy-lb
* myp-dev-k8s-wroker-incoming-from-k8s-master
* myp-dev-k8s-wroker-egress-to-k8s-master
* myp-dev-k8s-outgoing-to-haproxy-lb-allow
* myp-dev-k8s-incoming-from-gcp-helath-service
**Buckets:**
* Bucket name: myp-dev-{uniqueid}-secure-bukcet
  * Unique id can be configured in the dev.tfvars
  * Folder name: /k8s/master-node
* Permission
  * myp-k8s-master-sa@xxxxxx.gserviceaccount.com
  * myp-k8s-worker-sa@xxxxxx.gserviceaccount.com
  * myp-consul-sa@xxxxxx.gserviceaccount.com
  * myp-lb-haproxy-sa@xxxxxx.gserviceaccount.com
**VM Instances**
* myp-dev-consul-server
* myp-dev-haproxy-lb-1
* myp-dev-k8s-master-node
* myp-dev-k8s-worker-node-mig
* myp-dev-k8s-worker-node-bxsp	
**Instance Templates**
* myp-dev-k8s-worker-node-template
**Instance Groups**
* myp-dev-k8s-worker-node-mig
**Health Checks**
* myp-dev-k8s-worker-node-health-check
  * All health of nodes should be 100% healthy


## Install Web Applications K8s cluster
We deployed `nginx-web` as a sample application on the Kubernetes worker nodes and accessed it through the HAProxy load balancer.
As HAProxy is the chosen load balancer in our architecture, we configured an HAProxy Ingress Controller during the master node setup. This controller efficiently routes incoming traffic to the appropriate applications running within the pods.

### Install the HAProxy ingress controller into master VM in the GCP console
1. Login into ubuntu user and changed into home directory
```shell
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
3. Ensure Hproxy pods running properly in all worker nodes
```shell
kubectl get pods -n haproxy-controller -o wide

#Output
NAME                                        READY   STATUS      RESTARTS   AGE     IP                NODE                           NOMINATED NODE   READINESS GATES
haproxy-kubernetes-ingress-27lwj            1/1     Running     0          5m27s   192.168.100.1     myp-dev-k8s-worker-node-c3js   <none>           <none>
haproxy-kubernetes-ingress-crdjob-1-5rwd4   0/1     Completed   0          6m25s   192.168.100.2     myp-dev-k8s-worker-node-c3js   <none>           <none>
haproxy-kubernetes-ingress-khrxt            1/1     Running     0          4m56s   192.168.209.129   myp-dev-k8s-worker-node-0q3j   <none>           <none>
```

4. Ensure Hproxy service running properly in 30080 port
```shell
#Verify the service
kubectl get svc -n haproxy-controller haproxy-kubernetes-ingress

#Output
NAME                         TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                   AGE
haproxy-kubernetes-ingress   NodePort   10.97.64.228   <none>        80:30080/TCP,443:30443/TCP,443:30443/UDP,1024:30002/TCP   7m35s
```
5. Ensure Kube-proxy is Running Properly
If HAProxy is running on the worker node, but the port is not open, it could be due to issues with kube-proxy, which manages the network routing for services in Kubernetes.
Check if kube-proxy is running on the worker nodes:
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
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   9m3s
nginx-web    ClusterIP   10.111.110.192   <none>        80/TCP    1s
```
2. To Actually Spread Pods Across Multiple Nodes
```shell
kubectl scale deployment nginx-web --replicas=2

kubectl get pods -o wide -l app=nginx-web
```
Output:
```shell
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
3. Apply the ingress resource 
```shell
kubectl apply -f nginx-ingress.yaml
```
4. Identify the worker node Ip and test access of app through Node Port of worker node 
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
5. Identify the `haporxay` external Ip address from GCP console and execute following command on browser
```shell
http://<haproxy-vm-external-ip>
```

## Destroy the resources in GCP account
Execute following commands to destroy / clean the resources which are created on GCP
```shell
terraform destroy -var-file="dev.tfvars"
```

Source Code : (setup-k8s-cluster-on-gcp)[https://github.com/developerhelperhub/setup-k8s-cluster-on-gcp]

# Debug the services
Following git repo contains the all debug documents to debug the issues 
* (Debug Notes)[https://github.com/developerhelperhub/setup-k8s-cluster-on-gcp/debugs]
* Verify VMS installation
* Verify storage
* Verify the consul
* Verify the master node
* Verify the HAProxy