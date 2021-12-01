#Objectives
    # Create secrets by using the kubectl command and manifest files

    # Create ConfigMaps by using the kubectl command and manifest files

    # Consume secrets in containers by using environment variables or mounted volumes

    # Consume ConfigMaps in containers by using environment variables or mounted volumes


export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

#export my_service_account=[MY-SERVICE-ACCOUNT-EMAIL]

export my_service_account=no-permissions@qwiklabs-gcp-03-6e083c793af5.iam.gserviceaccount.com


gcloud container clusters create $my_cluster \
  --num-nodes 2 --zone $my_zone \
  --service-account=$my_service_account
############################################################################
#### Set up Cloud Pub/Sub and deploy an application to read from the topic
############################################################################
export my_pubsub_topic=echo
export my_pubsub_subscription=echo-read

# create a Cloud Pub/Sub topic named echo and a subscription named echo-read that is associated with that topic
gcloud pubsub topics create $my_pubsub_topic
gcloud pubsub subscriptions create $my_pubsub_subscription \
 --topic=$my_pubsub_topic

###### Deploy an application to read from Cloud Pub/Sub topics
    #  create a deployment with a container that can read from Cloud Pub/Sub topics
    #  specific permissions are required to subscribe to, and read from, Cloud Pub/Sub topics this container needs to be provided with credentials in order to successfully connect to Cloud Pub/Sub.

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Secrets/

# Deploy the application
kubectl apply -f pubsub.yaml

# Query pods label of app: pubsub.
kubectl get pods -l app=pubsub

# Inspect logs
kubectl logs -l app=pubsub
### Create service account credentials in GCloud conosle
    # Create role Pub/Sub Subscriber.
    # Create managed key for service account (download JSON and upload to cloud shell)
    # Upload file and upload the credentials.json

kubectl create secret generic pubsub-key \
 --from-file=key.json=$HOME/credentials.json

##### Configure the application with the secret
    # Add a volume to the Pod specification. This volume contains the secret.
    # The secrets volume is mounted in the application container.
    # The GOOGLE_APPLICATION_CREDENTIALS environment variable is set to point to the key file in the secret volume mount.



# --- To be continue...