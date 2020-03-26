# Kubernetes

## List nodes
```
$ kubectl get nodes
```

## Create a pod
```
$ kubectl create -f sa-frontend-pod.yaml
```

## Check status of pod
```
$ kubectl get pods [--watch]
```

--watch: to update info of status


## List all resources
```
$ kubectl get all
```

## Forward Port
```
$ kubectl port-forward <pod-name> <external-port>:<internal-port>
```

## Delete a specificed resource
```
$ kubectl delete [service|deployment]/<resource-name>
```

## Delete [all] deployment first
```
$ kubectl delete --all deployments
```

## Get deployment yaml
```
$ kubectl get deploy -n monitoring -o yaml --export
```

## Delete terminating pod
```
$ kubectl delete pod <pod-name> -n monitoring --grace-period 0 --force
```

## Connect to the remote cluster
1. Download the ```kubeconfig.yaml``` file containing access token to the remote cluster
2. Copy some part in ```kubeconfig.yaml``` into ```~/.kube/config```:
    - cluster:
    ```
    - cluster:
        certificate-authority-data: LS0tLS...0tLS0K
        server: https://a058b403-...-edf5bc188ddd.k8s.ondigitalocean.com
      name: do-sfo2-k8s-v-chain
    ```

    - context:
    ```
    - context:
        cluster: do-sfo2-k8s-v-chain
        user: do-sfo2-k8s-v-chain-admin
      name: do-sfo2-k8s-v-chain
    ```

    - user:
    ```
    - name: do-sfo2-k8s-v-chain-admin
      user:
        token: a122c27a1a969e749e57...c254e5f52422
    ```
3. Check contexts
```
$ kubectl config get-contexts
```
4. Switch default context
```
$ kubectl config use-context <context-name>
```
5. Check connection
```
$ kubectl get nodes
```

## Delete all resources in a namespace
```
$ kubectl delete all --all -n <namespace>
```
#
# Minikube

## Delete all minikube
```
$ minikube delete
```

## Start minikube
```
$ minikube start --vm-drive=none
```

## List services
```
$ minikube service list
```

#
# Helm

## Add stable repo
```
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

## Update repo
```
$ helm repo update
```

## Down the value of version
```
$ helm inspect values stable/prometheus
```

## Fetch chart
```
$ helm fetch stable/<name-chart>
```

