az login
https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash

terraform apply -auto-approve -var-file .terraformrc

terraform destroy -var-file .terraformrc