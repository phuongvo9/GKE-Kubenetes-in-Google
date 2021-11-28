# Create and test a private cluster

# Configure a cluster for authorized network master access

# Configure a Cluster network policy

gcloud beta container --project "qwiklabs-gcp-01-811c28398b48" clusters create "private-cluster" \
    --zone "us-central1-a" \
    --no-enable-basic-auth \
    --cluster-version "1.21.5-gke.1302" \
    --release-channel "regular" \
    --machine-type "e2-medium" \
    --image-type "COS_CONTAINERD" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --max-pods-per-node "110" --num-nodes "2" \
    --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM \
    --enable-private-nodes --master-ipv4-cidr "172.16.0.0/28" \
    --enable-ip-alias --network "projects/qwiklabs-gcp-01-811c28398b48/global/networks/default" \
    --subnetwork "projects/qwiklabs-gcp-01-811c28398b48/regions/us-central1/subnetworks/default" \
    --no-enable-intra-node-visibility --default-max-pods-per-node "110" \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
    --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes \
    --node-locations "us-central1-a"

gcloud container clusters describe private-cluster --region us-central1-a

# privateEndpoint, an internal IP address. Nodes use this internal IP address to communicate with the cluster master.
# publicEndpoint, an external IP address. External services and administrators can use the external IP address to communicate with the cluster master.

# We have several options to lock down our cluster to varying degrees:

# The whole cluster can have external access.
# The whole cluster can be private.
# The nodes can be private while the cluster master is public, and you can limit which external networks are authorized to access the cluster master.


#######################################
####Create a cluster network policy#####

# 1 Create another GKE cluster
export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

gcloud container clusters create $my_cluster --num-nodes 3 --enable-ip-alias --zone $my_zone --enable-network-policy

gcloud container clusters get-credentials $my_cluster --zone $my_zone

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/GKE_Networks/

# Restrict incoming traffic to Pods
        # kind: NetworkPolicy
        # apiVersion: networking.k8s.io/v1
        # metadata:
        # name: hello-allow-from-foo
        # spec:
        # policyTypes:
        # - Ingress
        # podSelector:
        #     matchLabels:
        #     app: hello
        # ingress:
        # - from:
        #     - podSelector:
        #         matchLabels:
        #         app: foo
kubectl apply -f hello-allow-from-foo.yaml

kubectl get networkpolicy



### Validate the ingress policy

# Run a temporary Pod called test-1 with the label app=foo and get a shell in the Pod.
kubectl run test-1 --labels app=foo --image=alpine --restart=Never --rm --stdin --tty

        # --stdin ( alternatively -i ) creates an interactive session attached to STDIN on the container.

        # --tty ( alternatively -t ) allocates a TTY for each container in the pod.

        # --rm instructs Kubernetes to treat this as a temporary Pod that will be removed as soon as it completes its startup task. As this is an interactive session it will be removed as soon as the user exits the session.

        # --label ( alternatively -l ) adds a set of labels to the pod.

        # --restart defines the restart policy for the Pod


# Make a request to the hello-web:8080 endpoint to verify that the incoming traffic is allowed
wget -qO- --timeout=2 http://hello-web:8080


# run a different Pod using the same Pod name but using a label, app=other, that does not match the podSelector in the active network policy. This Pod should not have the ability to access the hello-web application

kubectl run test-1 --labels app=other --image=alpine --restart=Never --rm --stdin --tty
wget -qO- --timeout=2 http://hello-web:8080



##########################################
# Restrict outgoing traffic from the Pods
##########################################
        # kind: NetworkPolicy
        # apiVersion: networking.k8s.io/v1
        # metadata:
        # name: foo-allow-to-hello
        # spec:
        # policyTypes:
        # - Egress
        # podSelector:
        #     matchLabels:
        #     app: foo
        # egress:
        # - to:
        #     - podSelector:
        #         matchLabels:
        #         app: hello
        # - to:
        #     ports:
        #     - protocol: UDP
        #     port: 53
kubectl apply -f foo-allow-to-hello.yaml

kubectl get networkpolicy

# Validate the egress policy

kubectl run hello-web-2 --labels app=hello-2 \
  --image=gcr.io/google-samples/hello-app:1.0 --port 8080 --expose

# Run a temporary Pod with the app=foo label and get a shell prompt inside the container.
kubectl run test-3 --labels app=foo --image=alpine --restart=Never --rm --stdin --tty
# Verify that the Pod can establish connections to hello-web:8080
wget -qO- --timeout=2 http://hello-web:8080




# Verify that the Pod cannot establish connections to hello-web-2:8080.

wget -qO- --timeout=2 http://hello-web-2:8080
    # This fails because none of the Network policies you have defined allow traffic to Pods labelled app: hello-2

# Verify that the Pod cannot establish connections to external websites, such as www.example.com
wget -qO- --timeout=2 http://www.example.com
