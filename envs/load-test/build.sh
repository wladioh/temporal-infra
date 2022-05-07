cd docker

ACR_NAME=$1
IMAGE_NAME=$2

az acr login --name $ACR_NAME

az acr build --registry $ACR_NAME --image $IMAGE_NAME .
