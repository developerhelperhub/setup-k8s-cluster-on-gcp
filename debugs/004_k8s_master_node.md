1. Verify helm  installed 
```shell
sudo su ubuntu

helm version
```
2. Verify the nodes are joined in the K8s cluster. Execute following command 
```shell
kubectl get nodes
```

3. Verify the pods are installed eg: network plugin (Calico in this case)
```shell
##Check the pods
kubectl get pods --all-namespaces
```

4. Ensur Hproxy pods running properly
```shell
kubectl get pods -n haproxy-controller -o wide
```