# OVERVIEW
    ## build a GKE cluster and then deploy pods for use with Kubernetes Engine Monitoring. 
    ## create charts and a custom dashboard, work with custom metrics, and create and respond to alerts.

# OBJECTIVES
    ## Use Kubernetes Engine Monitoring to view cluster and workload metrics
    ## Use Cloud Monitoring Alerting to receive notifications about the cluster’s health

#-----------------------------------------------------------------------------------------------------

    # Configuring a GKE cluster with Kubernetes Engine Monitoring

export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

# Create a VPC-native Kubernetes cluster with native Kubernetes monitoring enabled
gcloud container clusters create $my_cluster \
--num-nodes 3 --enable-ip-alias --zone $my_zone  \
--enable-stackdriver-kubernetes


git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Monitoring/


kubectl create -f hello-v2.yaml
kubectl get deployments


##################################################
###Deploy the GCP-GKE-Monitor-Test application
##################################################
#https://github.com/GoogleCloudPlatform/training-data-analyst/tree/master/courses/ak8s/v1.1/Monitoring/gcp-gke-monitor-test
export PROJECT_ID="$(gcloud config get-value project -q)"
cd gcp-gke-monitor-test

#  build the Docker image for the load testing application and push the image to the Google gcr.io registry
gcloud builds submit --tag=gcr.io/$PROJECT_ID/gcp-gke-monitor-test .

# Alternatively, we can also use Docker directly to build and push an image to gcr.io
    docker build -t gcr.io/${PROJECT_ID}/gcp-gke-monitor-test .

cd ..
