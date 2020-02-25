## build docker image
```
# docker build -t <image name> .
```

the dot means that building image from Dockerfile in the current local directory

## run docker container from an image
```
# docker run <image name>
```

## Issue: Get net/http: request canceled while waiting for connection
```
Change DNS into 1.1.1.1, 8.8.4.4
```

## list all running container
```
# docker ps
```

## list all container
```
# docker ps -a
```

## start a container 
```
# docker start <container id>
```

## map localhost port to container port
```
# docker start <container id> -p <localhost port>:<container port>
```

## stop a container
```
# docker stop <container id>
```

## stop all running containers
```
$ sudo docker stop $(sudo docker ps -q)
```

## show info of container
```
# docker inspect <container-id>
```

## remove all containers
```
$ sudo docker rm $(sudo docker ps -a -q)
```