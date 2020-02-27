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

# Monitoring Kong Ingress using Prometheus (log controller) and Grafana (Visaulizer)

## Prerequisites
- clusters
- helm

## Implement
1. Create the ```monitoring``` namespace:
- Create ```monitoring-namespace.yaml``` file
```
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```
- Create namespace
```
$ kubectl create -f monitoring-namespace.yaml
```


2. Install Prometheus:
- Create value file ```prometheus-values.yaml```
```
server:
  global:
    scrape_interval: 10s
```
- Install Prometheus using these values
```
$ helm install prometheus stable/prometheus --namespace monitoring --values prometheus-values.yaml
``` 

3. Install Grafana with server root path ```/grafana```:
- Fetch ```stable/grafana``` chart in local
```
$ kubectl fetch stable/grafana
```

- Extract ```grafana-5.0.3.tgz``` to ```grafana-5.0.3``` directory

- Edit ```values.yaml``` in ```./grafana-5.0.3/grafana/``` directory
```
...

grafana.ini:
  server:                         # set server root url
    path: /grafana/               # with prefix url: /grafana/
    serve_from_sub_path: true     # 
  paths:
    data: /var/lib/grafana/data
    logs: /var/log/grafana
    plugins: /var/lib/grafana/plugins
    provisioning: /etc/grafana/provisioning

...
```

- Compress the modified chart, we got a new ```grafana-5.0.3.tgz```:
```
$ helm package ./grafana-5.0.3/grafana
```

- Create value file ```grafana-values.yaml```:
```
persistence:
  enabled: true
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-server
     access: proxy
     isDefault: true

dashboards:
  default:
    kong-dash:
      gnetId: 7424
      revision: 5
      datasource: Prometheus

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default
```
- Install Grafana using these values
```
$ helm install grafana grafana-5.0.3.tgz --namespace monitoring --values grafana-values.yaml
```

4. Install Kong Ingress
- Create ```kong-namespace.yaml```:
```
apiVersion: v1
kind: Namespace
metadata:
  name: kong
```

- Create ```kong namespace```:
```
$ kubectl create -f kong-namespace.yaml
```

- Create values file ```kong-values.yaml```:
```
admin:
  useTLS: false
readinessProbe:
  httpGet:
    scheme: HTTP
livenessProbe:
  httpGet:
    scheme: HTTP
ingressController:
  enabled: true
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8444"
```

- Install Kong Ingress:
```
$ helm install kong stable/kong --namespace kong --values kong-values.yaml
```

5. Add Prometheus plugin
- Create file ```kong-prometheus-plugin.yaml```:
```
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  labels:
    global: "true"
  name: prometheus
plugin: prometheus
```

- Apply the plugin
```
$ kubectl apply -f kong-prometheus-plugin.yaml
```

6. Install some sample services (for testing)
```
$ kubectl apply -f multiple-services.yaml
```

7. Configure routes for Kong
- Create Kong Ingress
  - Create file ```kong-ingress.yaml```:
  ```
  apiVersion: configuration.konghq.com/v1
  kind: KongIngress
  metadata:
    name: strip-path
  route:
    strip_path: true
  ```

  - Apply Kong Ingress:
  ```
  $ kubectl apply -f kong-ingress.yaml
  ``` 

- Create Ingress to create service routes (for testing):
  - Create ```ingress.yaml```:
  ```
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      configuration.konghq.com: strip-path
    name: sample-ingresses
  spec:
    rules:
    - http:
      paths:
      - path: /billing
        backend:
          serviceName: billing
          servicePort: 80
      - path: /comments
        backend:
          serviceName: comments
          servicePort: 80
      - path: /invoice
        backend:
          serviceName: invoice
          servicePort: 80
  ```
  - Apply the ingress:
  ```
  $ kubectl apply -f ingress.yaml
  ```
8. Create route to grafana server:

- Create ```monitoring-ingress.yaml```:
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    configuration.konghq.com: strip-path
  name: monitoring-ingress
  namespace: monitoring
spec:
  rules:
  - http:
      paths:
      - path: /grafana
        backend:
            serviceName: grafana
            servicePort: 80
```

- Apply the ingress:
```
$ kubectl apply -f monitoring-ingress.yaml
```

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

## 