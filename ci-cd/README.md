## Install Jenkins Docker in local

1. Create a bridge network
```
$ sudo docker network craete jenkins
```

2. Create volumes
```
$ sudo volume create jenkins-docker-certs
$ sudo volume create jenkins-data
```

3. Pull 2 images. Note that it should run in parallel to save time.
```
$ sudo docker image pull docker:bind
$ sudo docker image pull jenkinsci/blueocean
```

4. To execute Docker commands inside Jenkins node:
```
$ sudo docker container run --name jenkins-docker \
--detach \
--privileged \
--network jenkins \
--network-alias docker \
--env DOCKER_TLS_CERTDIR=/certs \
--volume jenkins-docker-certs:/certs/client \
--volume jenkins-data:/var/jenkins_home \
--volume "$HOME":/home \
docker:dind
```
    
5. Install Jenkins docker

```
$ sudo docker container run --name jenkins \
--network jenkins \
--env DOCKER_HOST=tcp://docker:2376 \
--env DOCKER_CERT_PATH=/certs/client \
--env DOCKER_TLS_VERIFY=1 \
--volume jenkins-data:/var/jenkins_home \
--volume jenkins-docker-certs:/certs/client:ro \
--volume "$HOME":/home \
--publish 8080:8080 \
jenkinsci/blueocean
```
#

## Deploy Jenkins onto Kubernetes 

1. Create ```jenkins``` namespace:
```
$ kubectl create ns jenkins
```

2. Install Jenkins 
```
$ kubectl -n jenkins apply -f ./jenkins/
```

3. Apply ```jenkins-ingress.yaml```:
```
$ kubectl -n jenkins apply -f jenkins-ingress.yaml
```

## Get init root password
```
$ kubectl exec -it `kubectl get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name}` cat /var/jenkins_home/secrets/initialAdminPassword
```
#

## Install ArgoCD
1. Create ```argocd``` namespace
```
$ kubectl create ns argocd
```

2. Install ArgoCD
```
$ kubectl -n argocd apply -f argocd-installation.yaml
```

3. Get init admin password
```
$ kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
``` 

4. Login with username: ```admin``` and password: {above password}

5. Apply application
```
$ kubectl -n argocd apply -f app.yaml
```