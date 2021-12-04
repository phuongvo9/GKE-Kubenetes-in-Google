# create namespaces within a GKE cluster, and then use role-based access control to permit a non-admin user to work with Pods in a specific namespace.

# Create namespaces for users to control access to cluster resources
# Create roles and rolebindings to control access within a namespace

export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/RBAC/

##############################
#Create a Namespace
##############################


