# Define, deploy and clean up a GKE Job

# Define, deploy and clean up a GKE CronJob

export my_zone=us-central1-a
export my_cluster=standard-cluster-1

# Configure kubectl tab completion for Cloud shell
source <(kubectl completion bash)
# configure access to the cluster for the kubectl
gcloud container clusters get-credentials $my_cluster --zone $my_zone