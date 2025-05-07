Check the bucket storage to verify whether the following files are uploaded
 
* /k8s/master-node/join_node.sh
  * This shell script is used to join worker nodes to the Kubernetes cluster. It will be downloaded and executed on each worker node during the setup process.
* /consol/agent-node/consul-agent.sh
  * This shell common shell script is used to install consul agent in the VM. It will be downloaded and executed on each agent nodes during the setup process.
* /consol/server-node/consol_env.sh
  * This shell script is used to join agent nodes of consul server. It will be downloaded and executed on each agent nodes during the setup process.
