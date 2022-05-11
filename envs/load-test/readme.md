init terraform base env

1 - Set `task_file` on .terraformrc ex: sample.terraformrc
2 - Connect to cluster `az aks get-credentials --resource-group loadtest --name load-test-cluster --overwrite-existing`
3 - Run `kubectl port-forward svc/locust 8089:8089`
4 - http://localhost:8089/