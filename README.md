
# Overview
This section explains how to setup the Kubernetes (K8s) Cluster in Google Cloud Platform with help of Terraform.

# Objective
In software architecture and microservice architecture design, we have to consider scalability, availability, performance our application.  I am considering the following design consider when we selecting the Kubernetes in the software architecture design.

- When our application required high performance, availability, scalabilities, security 
- When our application should have more control and maintenance in our infrastructure 
- When our  application has more complexity microservices design 
- When our application is choosing open source (Optional)

#### When not considering the K8s
- When our application is small, we can use cloud provide managed service eg (AWS ECS Fargate serverless technology)
- When our application shouldn’t required high throughput 
- When our application should reduce IT operational cost and maintain the infrastructure

#### In this setup, I have considered following points while building K8s in the GCP
- Terraform - Easily deploy, destroy, maintain the cluster
- HAProxy - Configured Open source Load Balancer instead of GCP Load Balancer
- GCP RBAC - Easily join the node in the cluster, Maintain the K8s related file in GCP Bucket and link the service account and bucket role with GCP Virtual Machine.
- Minimum Role - As best practice we should, we have to configure the minimum role in the infrastructure, eg : 
- Added following firewall rule, Public → HAProxy:80, HAProxy → K8s Worker Nodes:30080
- Public and Private Subnet - Isolate the application workload and network through subnets. 


# In Progress [source code available soon]......