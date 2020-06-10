# Deploy Mongodb on K8S

1. Helm install
```
$ helm install mongodb stable/mongodb -n db --set mongodbRootPassword=root_password,mongodbUsername=username,mongodbPassword=password,mongodbDatabase=db_name
```

To get the root password run:

    export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace db mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

To get the password for "vking34" run:

    export MONGODB_PASSWORD=$(kubectl get secret --namespace db mongodb -o jsonpath="{.data.mongodb-password}" | base64 --decode)

To connect to your database run the following command:

    kubectl run --namespace db mongodb-client --rm --tty -i --restart='Never' --image docker.io/bitnami/mongodb:4.2.3-debian-10-r31 --command -- mongo admin --host mongodb --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace db svc/mongodb 27017:27017 &
    mongo --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD
