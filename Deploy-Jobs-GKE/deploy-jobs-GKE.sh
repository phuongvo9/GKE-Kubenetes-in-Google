# Define, deploy and clean up a GKE Job

# Define, deploy and clean up a GKE CronJob

export my_zone=us-central1-a
export my_cluster=standard-cluster-1

# Configure kubectl tab completion for Cloud shell
source <(kubectl completion bash)
# configure access to the cluster for the kubectl
gcloud container clusters get-credentials $my_cluster --zone $my_zone
# prepare the YAML files
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Jobs_CronJobs

##############################
### CREATE AND RUN A JOB
##############################

kubectl apply -f example-job.yaml
# This Job computes the value of Pi to 2,000 places and then prints the result

# DESCRIBE job
kubectl describe job example-job

kubectl get pods
kubectl get jobs
# retrieve the log file from the Pod that ran the Job execute
kubectl logs [POD-NAME]

# Delete job
kubectl delete job example-job