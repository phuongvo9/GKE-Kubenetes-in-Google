# Configure and test a liveness probe

# Configure and test a readiness probe

#---#---#---#---#---#---#---#---#---#---#---#---#---#---#---#---#---#---

export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

gcloud container clusters get-credentials $my_cluster --zone $my_zone


git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Probes/

# Configure liveness probes
    #  deploy a liveness probe to detect applications that have transitioned from a running state to a broken state. Sometimes, applications are temporarily unable to serve traffic
    #  For example, an application might need to load large data or configuration files during startup. In such cases, you don't want to kill the application, but you don't want to send it requests either. Kubernetes provides readiness probes to detect and mitigate these situations. A Pod with containers reporting that they are not ready does not receive traffic through Kubernetes Services.
    # Readiness probes are configured similarly to liveness probes. The only difference is that you use the readinessProbe field instead of the livenessProbe field.
    # A Pod definition file called exec-liveness.yaml has been provided for you that defines a simple container called liveness running Busybox and a liveness probe that uses the cat command against the file /tmp/healthy within the container to test for liveness every 5 seconds. The startup script for the liveness container creates the /tmp/healthy on startup and then deletes it 30 seconds later to simulate an outage that the Liveness probe can detect.
# apiVersion: v1
# kind: Pod
# metadata:
#   labels:
#     test: liveness
#   name: liveness-exec
# spec:
#   containers:
#   - name: liveness
#     image: k8s.gcr.io/busybox
#     args:
#     - /bin/sh
#     - -c
#     - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
#     livenessProbe:
#       exec:
#         command:
#         - cat
#         - /tmp/healthy
#       initialDelaySeconds: 5
#       periodSeconds: 5


kubectl create -f exec-liveness.yaml
kubectl describe pod liveness-exec
