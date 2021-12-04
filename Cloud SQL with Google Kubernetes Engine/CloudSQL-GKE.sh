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


export SQL_NAME=[Cloud SQL Instance Name]