# Create deployment manifests, deploy to cluster, and verify Pod rescheduling as nodes are disabled

# Trigger manual scaling up and down of Pods in deployments

# Trigger deployment rollout (rolling update to new version) and rollbacks

# Perform a Canary deployment




export my_zone=us-central1-a
export my_cluster=standard-cluster-1

gcloud auth list
gcloud config list project

#Configure kubectl tab completion in Cloud Shell.
source <(kubectl completion bash)
# Get GKE credential
gcloud container clusters get-credentials $my_cluster --zone $my_zone