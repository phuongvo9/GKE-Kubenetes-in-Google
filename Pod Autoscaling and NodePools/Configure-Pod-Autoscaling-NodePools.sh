################################################################################################
# Configure autoscaling and HorizontalPodAutoscaler
# Add a node pool and configure taints on the nodes for Pod anti-affinity
# Configure an exception for the node taint by adding a toleration to a Pod's manifest
################################################################################################


gcloud auth list