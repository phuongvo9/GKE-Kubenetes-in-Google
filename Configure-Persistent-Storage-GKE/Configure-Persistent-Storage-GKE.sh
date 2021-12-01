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


