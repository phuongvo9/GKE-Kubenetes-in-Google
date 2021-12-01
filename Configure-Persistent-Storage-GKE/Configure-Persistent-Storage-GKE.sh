# Create manifests for PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs) for Google Cloud persistent disks (dynamically created or existing)

# Mount Google Cloud persistent disk PVCs - PersistentVolumeClaims as volumes in Pods

# Use manifests to create StatefulSets

# Mount Google Cloud persistent disk PVCs as volumes in StatefulSets

# Verify the connection of Pods in StatefulSets to particular PVs as the Pods are stopped and restarted

gcloud auth list
gcloud config list project

########################
# Create PVs and PVCs
########################

export my_zone=us-central1-a
export my_cluster=standard-cluster-1

source <(kubectl completion bash)
gcloud container clusters get-credentials $my_cluster --zone $my_zone

# Create and apply a manifest with a PVC

    # don't need to directly configure PV objects or create Compute Engine persistent disks
    # create a PVC, and Kubernetes automatically provisions a persistent disk
    # create pvc-demo.yaml
            # apiVersion: v1
            # kind: PersistentVolumeClaim
            # metadata:
            # name: hello-web-disk
            # spec:
            # accessModes:
            #     - ReadWriteOnce
            # resources:
            #     requests:
            #     storage: 30Gi

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Storage/

# Check PVCs
kubectl get persistentvolumeclaim

kubectl apply -f pvc-demo.yaml
kubectl get persistentvolumeclaim


#################################################################
# Mount and verify Google Cloud persistent disk PVCs in Pods @@@
#################################################################
    #  attach the persistent disk PVC to a Pod.  mount the PVC as a volume as part of the manifest for the Pod.

    # The manifest file pod-volume-demo.yaml deploys an nginx container, attaches the pvc-demo-volume to the Pod and mounts that volume to the path /var/www/html inside the nginx container.
    # Files saved to this directory inside the container will be saved to the persistent volume and persist even if the Pod and the container are shutdown and recreated.
                    # kind: Pod
                    # apiVersion: v1
                    # metadata:
                    # name: pvc-demo-pod
                    # spec:
                    # containers:
                    #     - name: frontend
                    #     image: nginx
                    #     volumeMounts:
                    #     - mountPath: "/var/www/html"
                    #         name: pvc-demo-volume
                    # volumes:
                    #     - name: pvc-demo-volume
                    #     persistentVolumeClaim:
                    #         claimName: hello-web-disk


kubectl apply -f pod-volume-demo.yaml

kubectl get pods

# verify the PVC is accessible within the Pod
kubectl exec -it pvc-demo-pod -- sh

# create a simple text message as a web page in the Pod
    echo Test webpage in a persistent volume!>/var/www/html/index.html
    chmod +x /var/www/html/index.html
    cat /var/www/html/index.html
    exit
###################
## Test the persistence of the PV by deleting the pod
##################

kubectl delete pod pvc-demo-pod
kubectl get pods
    # show PVC
kubectl get persistentvolumeclaim
    # Redeploy the pvc-demo-pod.

kubectl apply -f pod-volume-demo.yaml

    # The Pod will deploy and the status will change to "Running" faster this time because the PV already exists and does not need to be create
# verify the PVC is is still accessible within the Pod,
kubectl exec -it pvc-demo-pod -- sh

    cat /var/www/html/index.html
    #Output: Test webpage in a persistent volume!



#################################################################
# Create StatefulSets with PVCs
# Note:  StatefulSet is like a Deployment, except that the Pods are given unique identifiers
#################################################################

kubectl delete pod pvc-demo-pod
kubectl get pods


#### Create a StatefulSet
    # cat statefulset-demo.yaml
    # creates a StatefulSet that includes a LoadBalancer service and three replicas of a Pod containing an nginx container and a volumeClaimTemplate for 30 gigabyte PVCs with the name hello-web-disk. The nginx containers mount the PVC called hello-web-disk at /var/www/html

            # kind: Service
            # apiVersion: v1
            # metadata:
            # name: statefulset-demo-service
            # spec:
            # ports:
            # - protocol: TCP
            #     port: 80
            #     targetPort: 9376
            # type: LoadBalancer
            # ---
            # apiVersion: apps/v1
            # kind: StatefulSet
            # metadata:
            # name: statefulset-demo
            # spec:
            # selector:
            #     matchLabels:
            #     app: MyApp
            # serviceName: statefulset-demo-service
            # replicas: 3
            # updateStrategy:
            #     type: RollingUpdate
            # template:
            #     metadata:
            #     labels:
            #         app: MyApp
            #     spec:
            #     containers:
            #     - name: stateful-set-container
            #         image: nginx
            #         ports:
            #         - containerPort: 80
            #         name: http
            #         volumeMounts:
            #         - name: hello-web-disk
            #         mountPath: "/var/www/html"
            # volumeClaimTemplates:
            # - metadata:
            #     name: hello-web-disk
            #     spec:
            #     accessModes: [ "ReadWriteOnce" ]
            #     resources:
            #         requests:
            #         storage: 30Gi
kubectl apply -f statefulset-demo.yaml

###############################################################
############## Verify the connection of Pods in StatefulSets
kubectl describe statefulset statefulset-demo
#Info out:
    # Normal  SuccessfulCreate  10s   statefulset-controller
    # Message: create Claim hello-web-disk-statefulset-demo-0 Pod statefulset-demo-0 in StatefulSet statefulset-demo success
    # Normal  SuccessfulCreate  10s   statefulset-controller
    # Message: create Pod statefulset-demo-0 in StatefulSet statefulset-demo successful
kubectl get pods
kubectl get pvc
kubectl describe pvc hello-web-disk-statefulset-demo-0


########################################################################################
# Verify the persistence of Persistent Volume connections to Pods managed by StatefulSets
#   verify the connection of Pods in StatefulSets to particular PVs as the Pods are stopped and restarted.
#####################################################################################33

# verify the connection of Pods in StatefulSets to particular PVs as the Pods are stopped and restarted.
kubectl exec -it statefulset-demo-0 -- sh

    cat /var/www/html/index.html
    # create a simple text message as a web page
    echo Test webpage in a persistent volume!>/var/www/html/index.html
    chmod +x /var/www/html/index.html

    cat /var/www/html/index.html

# Delete the Pod where I updated the file on the PVC
kubectl delete pod statefulset-demo-0

kubectl get pods
### StatefulSet is automatically restarting the statefulset-demo-0 Pod.

# Connect to the shell on the new statefulset-demo-0 Pod.

kubectl exec -it statefulset-demo-0 -- sh

    cat /var/www/html/index.html
    # Output: Test webpage in a persistent volume!
    exit



    
