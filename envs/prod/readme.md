az aks get-credentials --resource-group temporal --name temporal-cluster --overwrite-existing

kubectl get secret --namespace observability grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo