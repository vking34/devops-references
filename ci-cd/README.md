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

4. Get init root password
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

3. (Optional) Change Argo service type to ```LoadBalancer``` type so that we access Argo Server by a specific IP

4. (Optional) If your browser prevent from accessing the Argo Server with error: __ERR_CERT_INVALID__ then try to type ```thisisunsafe``` on this tab

4. Get init admin password
```
$ kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
``` 

4. Login with username: ```admin``` and password: {above password}

#

## Setup CI

### Pre-requistes:
+ Kubernetes Plugin
+ Github Integration Plugin
+ Add webhook to git repository with http(s)://[jenkins-server-ip]/github-webhook/ (For example: http://139.59.220.81/github-webhook/)

### Setup jenkins slave to build
1. Manage Jenkins > Manage Nodes and Clouds > Configure Cloud > Add a new cloud > Kubernetes

2. Configure Clouds:
    * Name: kubernetes
    * Kubernetes URL: https://kubernetes.default:443
    * Kubernetes Namespace: jenkins
    * Credentials > Add > Jenkins > Choose Kubernetes service account option & Global > Save
    * Test Connection. Should be successful! If not, check RBAC permissions and fix it!
    * Jenkins URL: http://jenkins
    * Tunnel : jenkins:50000
    * Add Kubernetes Pod Template
        * Name: jenkins-slave
        * Namespace: jenkins
        * Labels: jenkins-slave (you will need to use this label on all jobs)
        * Containers > Add Template
            * Name: jnlp
            * Docker Image: aimvector/jenkins-slave
            * Command to run : (Make this blank)
            * Arguments to pass to the command: (Make this blank)
            * Allocate pseudo-TTY: yes
            * Add Volume
                * Host Path type
                * HostPath: /var/run/docker.sock
                * Mount Path: /var/run/docker.sock
        * Timeout in seconds for Jenkins connection: 300
    * Save

### Add a pipeline
1. New item > Enter an item name > Pipeline > OK
2. General: Check Github project then give the repo URL
3. Build triggers: Github hook trigger for GITScm polling
4. Pipeline:
    - Definition: Pipeline script from SCM
    - SCM: Git
    - Repositories: Git URL (https://github.com/vking34/devops-references.git)
    - Branches: master (default)
    - Script Path: Jenkinsfile (default)

#
## Setup CD

### Pre-requistes:
- Deployment Repository separated from App repository (that follows GitOps). For example: https://github.com/vking34/sample-app-deployments

### Deployments for sample app

1. Apply staging app
```
$ kubectl -n argocd apply -f staging-app.yaml
```

2. Apply prod app
```
$ kubectl -n argocd apply -f prod-app.yaml
```

#

## Install Jenkins Docker in local *(for study only, not implementation)*

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