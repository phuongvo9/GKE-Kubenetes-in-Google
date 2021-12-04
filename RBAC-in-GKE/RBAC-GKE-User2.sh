export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

touch production-pod.yaml


kubectl apply -f ./production-pod.yaml
# Output
# Error from server (Forbidden): error when creating "production-pod.yaml": pods is forbidden: User "student-01-6d181293df2d@qwiklabs.net" cannot create resource "pods" in API group "" in the namespace "production": requires one of ["container.pods.create"] permission(s).

# After User1 create RoleBinding Pod Editor for User2, User2 is able to create and and list pods
kubectl apply -f ./production-pod.yaml
kubectl get pod -n production

kubectl delete pod production-pod --namespace production
    # This fails because Username 2 does not have the delete permission for Pods.