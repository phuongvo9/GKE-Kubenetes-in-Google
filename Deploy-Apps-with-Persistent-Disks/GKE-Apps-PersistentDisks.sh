#  configure a highly available application by deploying WordPress using regional persistent disks on Kubernetes Engine. Regional persistent disks provide synchronous replication between two zones, which keeps your application up and running in case there is an outage or failure in a single zone. Deploying a Kubernetes Engine Cluster with regional persistent disks will make your application more stable, secure, and reliable.
######################################################
### Creating the Regional Kubernetes Engine Cluster
######################################################


CLUSTER_VERSION=$(gcloud container get-server-config --region us-west1 --format='value(validMasterVersions[0])')

export CLOUDSDK_CONTAINER_USE_V1_API_CLIENT=false

gcloud container clusters create repd \
  --cluster-version=${CLUSTER_VERSION} \
  --machine-type=n1-standard-4 \
  --region=us-west1 \
  --num-nodes=1 \
  --node-locations=us-west1-a,us-west1-b,us-west1-c

######################################################
### Deploying the App with a Regional Disk
######################################################
    # Add the stable chart repository to Helm (a toolset for managing Kubernetes packages)
    # Create the Kubernetes StorageClass that is used by the regional persistent disk
    # Deploy WordPress

# Add the stable chart repository:
helm repo add stable https://charts.helm.sh/stable
helm repo update


# Create the StorageClass
kubectl apply -f - <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: repd-west1-a-b-c
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: regional-pd
  zones: us-west1-a, us-west1-b, us-west1-c
EOF