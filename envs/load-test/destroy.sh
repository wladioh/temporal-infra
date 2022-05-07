ACR_NAME=$1
IMAGE_NAME=$2

az acr repository delete --name $ACR_NAME --image $IMAGE_NAME --yes
