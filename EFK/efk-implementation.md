
# EFK (Elasticsearch, Fluentd, Kibana)
## Prerequisites
- Cluster
- kubectl
- helm
- Add elastic repo and kiwigrid repo
```
$ helm repo add elastic https://helm.elastic.co
$ helm repo add kiwigrid https://kiwigrid.github.io
$ helm repo update
```

#


1. Install ES
- Create ```es-values.yaml```
```
clusterName: elasticsearch

replicas: 1
minimumMasterNodes: 1

resources:
  requests:
    cpu: "100m"
    memory: "1Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
```

- Apply elasticsearch (version: 7.6.0)
```
$ helm install elasticsearch elastic/elasticsearch -n logging --values elasticsearch-values.yaml
```


2. Install Fluentd
- Create ```fluentd-values.yaml```
```
elasticsearch:
  host: elasticsearch-master
```

- Apply it
```
$ helm install fluentd kiwigrid/fluentd-elasticsearch -n logging --values fluentd-values.yaml
```

3. Install Kibana
- Create ```kibana-values.yaml```
```
elasticsearchHosts: "http://elasticsearch-master:9200"
```

- Apply it
```
$ helm install kibana elastic/kibana -n logging --values kibana-values.yaml
```

4. Create Kibana route for Kong Ingress
- Create ```logging-ingress.yaml```:
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    configuration.konghq.com: strip-path
  name: logging-ingress
  namespace: logging
spec:
  rules:
  - host: kibana.datochain.com
    http:
      paths:
      - path: /
        backend:
            serviceName: kibana-kibana
            servicePort: 5601

```

- Apply it
```
$ kubectl apply -f logging-ingress.yaml
```