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

# Inspect the HorizontalPodAutoscaler object

    # kubectl autoscale command we used in the previous step creates a HorizontalPodAutoscaler object that targets a specified resource, called the scale target, and scales it as needed. 
    # The autoscaler periodically adjusts the number of replicas of the scale target to match the average CPU utilization that we specify when creating the autoscaler.
# get the list of HorizontalPodAutoscaler resources
kubectl get hpa

    # Ouput
    # NAME   REFERENCE        TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
    # web    Deployment/web   <unknown>/1%   1         4         0          6s
kubectl describe horizontalpodautoscaler web

# view the configuration of HorizontalPodAutoscaler in YAML form
kubectl get horizontalpodautoscaler web -o yaml


################################################################################################
### Test the autoscale configuration
################################################################################################

# to create a heavy load on the web application to force it to scale out.
# create the load on our web application by deploying the loadgen application using the loadgen.yaml file

kubectl apply -f loadgen.yaml

kubectl get deployment
    # NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    # loadgen   4/4     4            4           28s
    # web       2/4     4            2           14m

kubectl get hpa
    # NAME   REFERENCE        TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
    # web    Deployment/web   80%/1%    1         4         4          7m22s


# stop the load on the web application, scale the loadgen deployment to zero replicas
kubectl scale deployment loadgen --replicas 0

kubectl get deployment
    # NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    # loadgen   0/0     0            0           117s
    # web       2/4     4            2           16m
kubectl get deployment

################################################################################################
### Manage Node Pools
################################################################################################
# ADD A NODE POOL
    # deploy a new node pool with three preemptible VM instances

gcloud container node-pools create "temp-pool-1" \
--cluster=$my_cluster --zone=$my_zone \
--num-nodes "2" --node-labels=temp=true --preemptible

# All the nodes that we added have the temp=true label because we set that label when we created the node-pool
kubectl get nodes