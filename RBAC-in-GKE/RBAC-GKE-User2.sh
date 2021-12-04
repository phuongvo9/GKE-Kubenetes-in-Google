export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

touch production-pod.yaml


kubectl apply -f ./production-pod.yaml