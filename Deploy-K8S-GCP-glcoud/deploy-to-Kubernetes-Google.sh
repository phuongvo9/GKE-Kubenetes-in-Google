# Creating Docker images on a host.
# Running Docker containers on a host.
# Storing Docker images in the Google Container Repository (GCR).
# Deploying GCR images on Kubernetes.
# Pushing updates onto Kubernetes.
# Automating deployments to Kubernetes using Jenkins.

source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking.sh)

# Clone app source code from Google source repository
export PROJECT=$DEVSHELL_PROJECT_ID
gcloud source repos clone valkyrie-app --project=$PROJECT

# Create Docker File
cat > Dockerfile <<EOF
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

# Build to Docker image
docker build -t valkyrie-app:v0.0.1 .

# Run docker from image
docker run -p 8080:8080 --name valkyrie-app valkyrie-app:v0.0.1 &


# Push the Docker image in the Container Repository
docker tag valkyrie-app:v0.0.1 gcr.io/$PROJECT/valkyrie-app:v0.0.1
docker images
docker push gcr.io/$PROJECT/valkyrie-app:v0.0.1

#get credential
gcloud container clusters get-credentials valkyrie-dev --zone us-east1-d --project qwiklabs-gcp-02-902d5faf9497

kubectl create -f k8s/service.yaml
kubectl create -f k8s/deployment.yaml


# Increase the replicas from 1 to 3
kubectl scale deployment valkyrie-dev --replicas 3


# Merge remote branch <kurt-dev> to origin/main
git merge origin/kurt-dev

# Build app image version 2 from Kurt's code
docker build -t valkyrie-app:v0.0.2 .
docker tag valkyrie-app:v0.0.2 gcr.io/$PROJECT/valkyrie-app:v0.0.2
docker images
docker push gcr.io/$PROJECT/valkyrie-app:v0.0.2

# Edit live deployment
kubectl edit deployment valkyrie-dev

# Get Jenkins password
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
# OEjS61fKT7mHj2QSVk2dNe
# Kill running container before accessing Jenkins
docker ps
docker container kill $(docker ps -aq)


# Connect to the Jenkins console using the commands port-foward
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
# Setup credentials + Jenkins configuration - create a pipeline in Jenkins to deploy app
    # Edit Jenkins File
# Configure Git to push to remote repos
git config --global user.email $PROJECT
git config --global user.name $PROJECT

git add *
git commit -m 'green to orange'
git push origin master

# Manually trigger the build in the Jenkins console

# Completed