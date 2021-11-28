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

