################################################################################################
# Configure autoscaling and HorizontalPodAutoscaler
# Add a node pool and configure taints on the nodes for Pod anti-affinity
# Configure an exception for the node taint by adding a toleration to a Pod's manifest
################################################################################################


gcloud auth list
gcloud config list project

# Connect to the GKE cluster
export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

gcloud container clusters get-credentials $my_cluster --zone $my_zone

# Deploy a sample web application to the GKE cluster - web.yaml
    # Refer to web.yaml

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Autoscaling/
kubectl create -f web.yaml --save-config

# Create a service resource of type NodePort on port 8080 for the web deployment
kubectl expose deployment web --target-port=8080 --type=NodePort

kubectl get service web


################################################################################################
# Configure autoscaling on the cluster
################################################################################################

kubectl get deployment
kubectl autoscale deployment web --max 4 --min 1 --cpu-percent 1

kubectl get deployment
