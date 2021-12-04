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

###################################
## Create a Resource in a Namespace
###################################

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

 
###################################
## Create Roles and RoleBindings
###################################

# -----create a custom role, and then create a RoleBinding that grants Username 2 the editor role in the production namespace.
    # pod-reader-role.yaml
            # kind: Role
            # apiVersion: rbac.authorization.k8s.io/v1
            # metadata:
            #   namespace: production
            #   name: pod-reader
            # rules:
            # - apiGroups: [""]
            #   resources: ["pods"]
            #   verbs: ["create", "get", "list", "watch"]
## -------------- Create a custome Role--------------------------------
    # Grant my account cluster-admin privileges
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user student-03-f7546ffe711b@qwiklabs.net
    # Create role pod-reader
kubectl apply -f pod-reader-role.yaml

kubectl get roles --namespace production

## ----------------Create a RoleBinding-----------------------------
    # Note: The role is used to assign privileges, but by itself it does nothing. The role must be bound to a user and an object, which is done in the RoleBinding
            # kind: RoleBinding
            # apiVersion: rbac.authorization.k8s.io/v1
            # metadata:
            # name: username2-editor
            # namespace: production
            # subjects:
            # - kind: User
            # name: [USERNAME_2_EMAIL]
            # apiGroup: rbac.authorization.k8s.io
            # roleRef:
            # kind: Role
            # name: pod-reader
            # apiGroup: rbac.authorization.k8s.io
export USER2=student-01-6d181293df2d@qwiklabs.net
sed -i "s/\[USERNAME_2_EMAIL\]/${USER2}/" username2-editor-binding.yaml
cat username2-editor-binding.yaml


kubectl apply -f username2-editor-binding.yaml

kubectl get rolebinding --namespace production
# Now username2 is able to create the Prod - POD
