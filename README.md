# DEPLOYMENT
Deployment repository
# CATALOGUE - SERVICE
## MongoDb
Create a folder in `./catalogue/mongoDb` named `keys`
Inside create a key named `mongo-replica-set.key` with the command :

``` bash
mkdir ./catalogue/mongoDb/keys
openssl rand -base64 756 > ./catalogue/mongoDb/keys/mongo-replica-set.key
# Change permissions
sudo chmod 600 ./catalogue/mongoDb/keys/mongo-replica-set.key
# Set owner : mongoDb
sudo chown 999:999 ./catalogue/mongoDb/keys/mongo-replica-set.key
```

## Env file
 Use the file .env.sample to create a .env file to set all variables
 


# Run 
Run `docker-compose up -d` to launch every needed container.


Sécurisation de l'APP : REST + Analyse de code + Authentification (OAuth2)
