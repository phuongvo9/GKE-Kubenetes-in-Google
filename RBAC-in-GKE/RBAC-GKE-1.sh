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


# Connect to GKE cluster
gcloud container clusters get-credentials $my_cluster --zone $my_zone

# Create production namespace
        # apiVersion: v1
        # kind: Namespace
        # metadata:
        # name: production

kubectl create -f ./my-namespace.yaml
kubectl get namespaces

kubectl describe namespaces production

##############################
## Create a Resource in a Namespace
##############################

    # Note: need to specify the namespace production when creating a new Pod - Otherwise, it will use "default" ns
            # apiVersion: v1
            # kind: Pod
            # metadata:
            # name: nginx
            # labels:
            #     name: nginx
            # spec:
            # containers:
            # - name: nginx
            #     image: nginx
            #     ports:
            #     - containerPort: 80

kubectl apply -f ./my-pod.yaml --namespace=production

kubectl get pods
kubectl get pods --namespace=production

