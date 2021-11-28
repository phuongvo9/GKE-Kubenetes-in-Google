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
# This label makes it easier to locate and configure these nodes
kubectl get nodes
kubectl get nodes -l temp=true


#### Control scheduling with taints and tolerations ########

# To prevent the scheduler from running a Pod on the temporary nodes, we add a taint to each of the nodes in the temp pool
# Taints are implemented as a key-value pair with an effect (such as NoExecute) that determines whether Pods can run on a certain node.
# Only nodes that are configured to tolerate the key-value of the taint are scheduled to run on these nodes.

kubectl taint node -l temp=true nodetype=preemptible:NoExecute

# Edit the web.yaml file to add the following key in the template's spec section
    # tolerations:
    # - key: "nodetype"
    #   operator: Equal
    #   value: "preemptible"
# To force the web deployment to use the new node-pool add a nodeSelector key in the template's spec section

    #  nodeSelector:
    #     temp: "true"
kubectl apply -f web-tolerations.yaml

### Verify the change
# inspect the running web Pod

kubectl describe pods -l run=web

# A Tolerations section with nodetype=preemptible in the list should appear near the bottom
    # <SNIP>
    # Node-Selectors:  temp=true
    # Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
    #                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
    #                 nodetype=preemptible
    # Events:
    # <SNIP>

# force the web application to scale out again scale the loadgen deployment back to four replicas
kubectl scale deployment loadgen --replicas 4
kubectl get pods -o wide
#  shows that the loadgen app is running only on default-pool nodes while the web app is running only the preemptible nodes in temp-pool-1



#####
#The taint setting prevents Pods from running on the preemptible nodes so the loadgen application only runs on the default pool.
# The toleration setting allows the web application to run on the preemptible nodes and the nodeSelector forces the web application Pods to run on those nodes.

    # NAME        READY STATUS    [...]         NODE
    # Loadgen-x0  1/1   Running   [...]         gke-xx-default-pool-y0
    # loadgen-x1  1/1   Running   [...]         gke-xx-default-pool-y2
    # loadgen-x3  1/1   Running   [...]         gke-xx-default-pool-y3
    # loadgen-x4  1/1   Running   [...]         gke-xx-default-pool-y4
    # web-x1      1/1   Running   [...]         gke-xx-temp-pool-1-z1
    # web-x2      1/1   Running   [...]         gke-xx-temp-pool-1-z2
    # web-x3      1/1   Running   [...]         gke-xx-temp-pool-1-z3
    # web-x4      1/1   Running   [...]         gke-xx-temp-pool-1-z4