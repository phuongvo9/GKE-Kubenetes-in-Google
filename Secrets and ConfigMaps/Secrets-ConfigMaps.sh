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

