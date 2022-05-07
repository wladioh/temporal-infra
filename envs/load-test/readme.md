init terraform base env

1 - Set `task_file` on .terraformrc ex: sample.terraformrc
1 - Run `kubectl port-forward svc/locust-master-web 8089:8089`
2 - http://localhost:8089/