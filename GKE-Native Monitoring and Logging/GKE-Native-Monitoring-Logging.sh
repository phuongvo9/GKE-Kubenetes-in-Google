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