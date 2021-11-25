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

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

# Create a soft link as a shortcut to the working director
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Deployments/

# create nginx-deployment.yaml
kubectl apply -f ./nginx-deployment.yaml

kubectl get deployments


### Manually scale up and down the number of Pods in deployments
# GUI GCP console or cmd
kubectl scale --replicas=1 deployment nginx-deployment

#
kubectl scale --replicas=3 deployment nginx-deployment


### Trigger a deployment rollout and a deployment rollback

    # update the container image in your Deployment to nginx v1.9.1.
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record

    # view the rollout status
kubectl rollout status deployment.v1.apps/nginx-deployment
        # Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
        # Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
        # deployment "nginx-deployment" successfully rolled out

