# Kubernetes DNS in action.

# Define various service types (ClusterIP, NodePort, LoadBalancer) in manifests along with label selectors to connect to existing labeled Pods and deployments, deploy those to a cluster, and test connectivity.

# Deploy an Ingress resource that connects clients to two different services based on the URL path entered.

# Verify Google Cloud network load balancer creation for type=LoadBalancer services.

export my_zone=us-central1-a
export my_cluster=standard-cluster-1

source <(kubectl completion bash)

gcloud container clusters get-credentials $my_cluster --zone $my_zone

# Create Pods and services to test DNS resolution
    # create a service called dns-demo with two sample application Pods called dns-demo-1 and dns-demo-2

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/GKE_Services/

kubectl apply -f dns-demo.yaml