# Kubernetes DNS in action.

# Define various service types (ClusterIP, NodePort, LoadBalancer) in manifests along with label selectors to connect to existing labeled Pods and deployments, deploy those to a cluster, and test connectivity.

# Deploy an Ingress resource that connects clients to two different services based on the URL path entered.

# Verify Google Cloud network load balancer creation for type=LoadBalancer services.

export my_zone=us-central1-a
export my_cluster=standard-cluster-1

source <(kubectl completion bash)

gcloud container clusters get-credentials $my_cluster --zone $my_zone

# Create Pods and services to test DNS resolution
    # create a service called dns-demo with two sample application Pods called dns-demo-1 and dns-demo-2

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/GKE_Services/

kubectl apply -f dns-demo.yaml

#  open an interactive session to bash running from dns-demo-1
kubectl exec -it dns-demo-1 -- /bin/bash

# install ping tool inside the pod
apt-get update
apt-get install -y iputils-ping

ping dns-demo-2.dns-demo.default.svc.cluster.local
    # PING dns-demo-2.dns-demo.default.svc.cluster.local (10.8.1.8) 56(84) bytes of data.
    # 64 bytes from dns-demo-2.dns-demo.default.svc.cluster.local (10.8.1.8): icmp_seq=1 ttl=62 time=1.69 ms
    # 64 bytes from dns-demo-2.dns-demo.default.svc.cluster.local (10.8.1.8): icmp_seq=2 ttl=62 time=0.327 ms
#Ping the dns-demo service's FQDN, instead of a specific Pod inside the service
ping dns-demo.default.svc.cluster.local

# Deploy a sample workload and a ClusterIP service
    # create a deployment manifest for a set of Pods within the cluster and then expose them using a ClusterIP service
# deploy a sample web application container image that listens on an HTTP server on port 8080 - hello-v1.yaml
kubectl create -f hello-v1.yaml

kubectl get deployments

# deploy a Service using a ClusterIP using the hello-svc.yaml

kubectl apply -f ./hello-svc.yaml

kubectl get service hello-svc

### TEST THE APPLICATION
    # open an HTTP session to the new service | Outside the cluster
curl hello-svc.default.svc.cluster.local
    #Output: curl: (6) Could not resolve host: hello-svc.default.svc.cluster.local

# Test inside
    # Go to a pod inside the cluster
kubectl exec -it dns-demo-1 -- /bin/bash
    apt-get install -y curl
        # curl is already the newest version (7.74.0-1.3+b1).
        # 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
        # root@dns-demo-1:/# curl hello-svc.default.svc.cluster.local
        # Hello, world!
        # Version: 1.0.0
        # Hostname: hello-v1-695896495d-7wq46
# Confirmed: This connection works because the clusterIP can be resolved using the internal DNS within the Kubernetes Engine cluster.

###################################################
### Convert the service to use NodePort
###################################################

    #  convert the existing ClusterIP service to a NodePort service and then retest access to the service from inside and outside the cluster.
# deploy the manifest that changes the service type for the hello-svc from ClusterIP to NodePort
kubectl apply -f ./hello-nodeport-svc.yaml

kubectl get service hello-svc
    #Output:
        # NAME        TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
        # hello-svc   NodePort   10.12.6.36   <none>        80:30100/TCP   9m46s

### Test the application with NodePort
curl hello-svc.default.svc.cluster.local
    # curl: (6) Could not resolve host: hello-svc.default.svc.cluster.local
# Inside the pod - can curl



###################################################
### Create static public IP addresses using Google Cloud Networking
###################################################

# Create in GCP console UI
    # Networking > VPC Network > External IP Addresses > + Reserve static address
        #Reserve: "regional-loadbalancer" - Type: Regional PUBLIC IP
        #Reservce: "global-ingress" - Type: Global Public IP

###################################################
### Deploy a new set of Pods and a LoadBalancer service
###################################################

# deploy a new set of Pods running a different version of the application
# expose the new Pods as a LoadBalancer service and access the service from outside the cluster.
# hello-v2.yaml

kubectl apply -f hello-v2.yaml

kubectl get deployments

# Define service types in the manifest - hello-lb-svc.yaml
    #  use the sed command to replace the 10.10.10.10 placeholder address in the load balancer yaml file with the static address



# save the regional static IP-address I created earlier 
export STATIC_LB=$(gcloud compute addresses describe regional-loadbalancer --region us-central1 --format json | jq -r '.address')
sed -i "s/10\.10\.10\.10/$STATIC_LB/g" hello-lb-svc.yaml
    # 34.132.116.131

cat hello-lb-svc.yaml
                # apiVersion: v1
                # kind: Service
                # metadata:
                # name: hello-lb-svc
                # spec:
                # type: LoadBalancer
                # loadBalancerIP: 34.132.116.131
                # selector:
                #     name: hello-v2
                # ports:
                # - protocol: TCP
                #     port: 80
                #     targetPort: 8080
kubectl get services
            # NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
            # dns-demo       ClusterIP      None          <none>        1234/TCP       35m
            # hello-lb-svc   LoadBalancer   10.12.10.49   <pending>     80:30277/TCP   24s
            # hello-svc      NodePort       10.12.6.36    <none>        80:30100/TCP   25m
            # kubernetes     ClusterIP      10.12.0.1     <none>        443/TCP        54m

### TEST The APplication version 2
curl $STATIC_LB
        # Hello, world!
        # Version: 2.0.0
        # Hostname: hello-v2-569cc4bf64-vw2pd


###############################################
##### Deploy an Ingress resource

# deploy an Ingress resource that will direct traffic to both services based on the URL entered by the user

# Create an ingress resource

            # apiVersion: app/v1
            # kind: Ingress
            # metadata:
            # name: hello-ingress
            # annotations:
            #     nginx.ingress.kubernetes.io/rewrite-target: /
            #     kubernetes.io/ingress.global-static-ip-name: "global-ingress"
            # spec:
            # rules:
            # - http:
            #     Paths:
            #     - path: /v1
            #         backend:
            #         serviceName: hello-svc
            #         servicePort: 80
            #     - path: /v2
            #         backend:
            #         serviceName: hello-lb-svc
            #         servicePort: 80

kubectl apply -f hello-ingress.yaml