## build docker image
```
$ docker build -t [dockerhub-username]/<image name>:[tag] .
```

the dot means that building image from Dockerfile in the current local directory

## run docker container from an image
```
$ docker run -p <localhost port>:<container port> <image name> 
```

## SSH into a running container
```
$ docker exec -it <container-name> /bin/bash
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

## push image to the docker hub
```
$ docker push [dockerhub-username]/<image name>:[tag]
```

## log into container
```
$ docker exec -it <container-name> <command> 
```
#

## Create Mysql Server in docker

1. Pull image
```
$ docker image pull mysql/mysql-server
```

2. Run container
```
$ docker run --name=mysql-server -e MYSQL_ROOT_HOST=% -p 3306:3306 -d mysql/mysql-server
```

3. Show the logs of the container to get the root password
```
$ docker logs <container-name>
```

4. Login the mysql server using the given password
```
$ docker exec -it <container-name> mysql -uroot -p
```

5. Change root password
```
$ ALTER USER 'root'@'localhost' IDENTIFIED BY 'new-password';
```