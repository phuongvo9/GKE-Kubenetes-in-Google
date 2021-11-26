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


##############################
### CREATE AND RUN A CronJob
##############################

# All CronJob times are in UTC
# Note

# CronJobs use the required schedule field, which accepts a time in the Unix standard crontab format. All CronJob times are in UTC:

# The first value indicates the minute (between 0 and 59).
# The second value indicates the hour (between 0 and 23).
# The third value indicates the day of the month (between 1 and 31).
# The fourth value indicates the month (between 1 and 12).
# The fifth value indicates the day of the week (between 0 and 6).
# The schedule field also accepts * and ? as wildcard values. Combining / with ranges specifies that the task should repeat at a regular interval. In the example, */1 * * * * indicates that the task should repeat every minute of every day of every month.

kubectl apply -f example-cronjob.yaml

kubectl get jobs

kubectl describe job [job_name]

kubectl logs [POD-NAME]
kubectl get jobs

# Delete cronjob
kubectl delete cronjob hello

kubectl get jobs