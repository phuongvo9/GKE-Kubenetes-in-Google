export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

gcloud beta container --project "qwiklabs-gcp-02-9f0ee146a114" clusters create "standard-cluster-1" --zone "us-central1-a" \
    --no-enable-basic-auth --cluster-version "1.21.5-gke.1302" --release-channel "regular" \
    --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" \
    --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --max-pods-per-node "110" --num-nodes "2" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM \
    --enable-ip-alias --network "projects/qwiklabs-gcp-02-9f0ee146a114/global/networks/default" \
    --subnetwork "projects/qwiklabs-gcp-02-9f0ee146a114/regions/us-central1/subnetworks/default" \
    --no-enable-intra-node-visibility --default-max-pods-per-node "110" \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade \
    --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes \
    --node-locations "us-central1-a"

gcloud container clusters get-credentials $my_cluster --zone $my_zone

################################################################
#### Create and Use Pod Security Policies
################################################################
    #enable pod security policy admission control on a cluster the default security policies \
    # configured by Kubernetes Engine prevent non-admin users running privileged pods

        # apiVersion: policy/v1beta1
        # kind: PodSecurityPolicy
        # metadata:
        #   name: restricted-psp
        # spec:
        #   privileged: false  # Don't allow privileged pods!
        #   seLinux:
        #     rule: RunAsAny
        #   supplementalGroups:
        #     rule: RunAsAny
        #   runAsUser:
        #     rule: MustRunAsNonRoot
        #   fsGroup:
        #     rule: RunAsAny
        #   volumes:
        #   - '*'


git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Security/