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

kubectl apply -f restricted-psp.yaml
kubectl get podsecuritypolicy restricted-psp
    # Output:
    # Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
    # NAME             PRIV    CAPS   SELINUX    RUNASUSER          FSGROUP    SUPGROUP   READONLYROOTFS   VOLUMES
    # restricted-psp   false          RunAsAny   MustRunAsNonRoot   RunAsAny   RunAsAny   false            *


################################################################
#### Create a ClusterRole for a pod security policy
##### --Bind Username 1 to the cluster admin role and create the restricted-pods role
################################################################

            # kind: ClusterRole
            # apiVersion: rbac.authorization.k8s.io/v1
            # metadata:
            # name: restricted-pods-role
            # rules:
            # - apiGroups:
            # - extensions
            # resources:
            # - podsecuritypolicies
            # resourceNames:
            # - restricted-psp
            # verbs:
            # - use
# Create an environment variable to store the mail address of my account
export USERNAME_1_EMAIL=$(gcloud info --format='value(config.account)')

# Grant my user account cluster-admin privileges
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $USERNAME_1_EMAIL

kubectl get clusterrole restricted-pods-role
   
    # ------ The new ClusterRole is ready, but it is not yet bound to a subject, and therefore is not yet active




################################################################
#### Activate Security Policy
################################################################
# PodSecurityPolicy controller must be enabled to affect the admission control of new Pods in the cluster
# Warning: If we do not define and authorize policies prior to enabling the PodSecurityPolicy controller, some accounts will not be able to deploy or run Pods on the cluster.


# enable the PodSecurityPolicy controller
gcloud beta container clusters update $my_cluster --zone $my_zone --enable-pod-security-policy