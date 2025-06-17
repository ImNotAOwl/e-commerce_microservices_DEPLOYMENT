#!/bin/bash

echo "########### Waiting for primary ###########"
until mongosh --host bs_catalogue-mongo-primary -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping ###########"
    sleep 5
  done

echo "########### Waiting for replica 01 ###########"
until mongosh --host bs_catalogue-mongo01 -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping ###########"
    sleep 5
  done

echo "########### Waiting for replica 02 ###########"
until mongosh --host bs_catalogue-mongo02 -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping ###########"
    sleep 5
  done

echo "########### All replicas are ready!!! ###########"

echo "########### Setting up cluster config ###########"
mongosh --host bs_catalogue-mongo-primary -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin <<EOF
rs.initiate(
   {
      _id: "rs0",
      version: 1,
      members: [
         { _id: 0, host : "bs_catalogue-mongo-primary:27017", priority: 2 },
         { _id: 1, host : "bs_catalogue-mongo01:27017", priority: 1 },
         { _id: 2, host : "bs_catalogue-mongo02:27017", priority: 1 }
      ]
   }
)
EOF

echo "########### Sleeping ###########"
sleep 10

echo "########### Setting up new user ###########"
mongosh --host bs_catalogue-mongo-primary -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin <<EOF
admin = db.getSiblingDB("admin")
admin.createUser(
  {
    user: "$CATALOG_USER",
    pwd: "$CATALOG_PASS",
    roles: [ { role: "readWrite", db: "$DB_SERVICE" } ]
  }
)
EOF

echo "########### Getting replica set status again ###########"
mongosh --host bs_catalogue-mongo-primary -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin <<EOF
rs.status()
EOF

# Mark initialization as done
mkdir -p /tmp/mongo-init
echo "Initialization complete" > /tmp/mongo-init/.init_done
sleep 45

echo "########### Stopping MONGO init  ###########"
mongod --shutdown
