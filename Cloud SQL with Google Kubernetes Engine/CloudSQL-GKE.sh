#### OVERVIEW
#set up a Kubernetes Deployment of WordPress connected to Cloud SQL via the SQL Proxy.
#The SQL Proxy lets you interact with a Cloud SQL instance as if it were installed locally (localhost:3306), and even though you are on an unsecured port locally, the SQL Proxy makes sure you are secure over the wire to your Cloud SQL Instance.

### OBJECTIVES
# Create a Cloud SQL instance and database for Wordpress

# Create credentials and Kubernetes Secrets for application authentication

# Configure a Deployment with a Wordpress image to use SQL Proxy

# Install SQL Proxy as a sidecar container and use it to provide SSL access to a CloudSQL instance external to the GKE Cluster


export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

gcloud container clusters get-credentials $my_cluster --zone $my_zone

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Cloud_SQL/

# Create a Cloud SQL instance
gcloud sql instances create sql-instance --tier=db-n1-standard-2 --region=us-central1

# Create an environment variable to hold the Cloud SQL instance name
export SQL_NAME=[Cloud SQL Instance Name]

# Connect to the Cloud SQL instance
gcloud sql connect sql-instance

create database wordpress;
use wordpress;
show tables;
exit;


### --- Prepare a Service Account with permission to access Cloud SQL
# create a Service Account > Role: Cloud SQL Client
# create key for service account > Download JSON key


### --- Create Secrets
# create a Secret for your MySQL credentials
kubectl create secret generic sql-credentials \
   --from-literal=username=sqluser\
   --from-literal=password=sqlpassword


# Upload key for service account to Cloud Shell
# mv ~/credentials.json .


# Create a Secret for your Google Cloud Service Account credentials
kubectl create secret generic google-credentials\
   --from-file=key.json=credentials.json
    # the file is uploaded to the Secret using the name key.json.
    # That is the file name that a container will see when this Secret is attached as a Secret Volume.



### --- Deploy the SQL Proxy agent as a sidecar container
#  deploys a demo Wordpress application container with the SQL Proxy agent as a sidecar container 
    # In the Wordpress container environment settings the WORDPRESS_DB_HOST is specified using the localhost IP address. \
    # The cloudsql-proxy sidecar container is configured to point to the Cloud SQL instance we created in the previous step. \
    # The database username and password are passed to the Wordpress container as secret keys, and the JSON credentials file is passed to the container using a Secret volume. 
    # A Service is also created to allow us to connect to the Wordpress instance from the internet.

sed -i 's/<INSTANCE_CONNECTION_NAME>/'"${SQL_NAME}"'/g'\
   sql-proxy.yaml

kubectl apply -f sql-proxy.yaml


kubectl get deployment wordpress
kubectl get services



