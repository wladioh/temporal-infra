init terraform base env

1 - Set `task_file` on .terraformrc ex: sample.terraformrc
2 - Connect to cluster `az aks get-credentials --resource-group $1 --name $2 --overwrite-existing`
3 - Run `kubectl port-forward svc/locust 8089:8089`
4 - http://localhost:8089/