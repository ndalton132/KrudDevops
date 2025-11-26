#!/bin/bash
echo "Starting initial deployment..."

if ! az account show &> /dev/null; then
    echo "Not logged in to Azure. Logging in..."
    az login
fi

cd terraform
terraform init -upgrade

terraform apply


########################################################################################################################
#Define variables
########################################################################################################################





export ACR_NAME=$(terraform output -raw acr_login_server)
ACR_SHORT=${ACR_NAME%.azurecr.io}
PSQL_HOST=$(terraform output -raw postgresql_server_fqdn)
PSQL_USER=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="azurerm_postgresql_flexible_server" and .name=="main") | .values.administrator_login')
PSQSL_PSWD=$(terraform state pull | jq -r '.resources[] | select(.type == "azurerm_postgresql_flexible_server") | .instances[0].attributes.administrator_password')

#Refresh AKS credentials
AZ_RG=$(terraform output -raw resource_group_name)
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
cd ..

az aks get-credentials \
  --resource-group $AZ_RG \
  --name $AKS_CLUSTER_NAME \
  --overwrite-existing


#########################################################################################################################
#Auto deploy and configure Azure container registry (ACR) for AKS
#########################################################################################################################
# Deploy ACR
# terraform apply -target=azurerm_container_registry.main -target=azurerm_role_assignment.aks_acr_pull

# # Get ACR name

# Login to ACR
az acr login --name $ACR_NAME

docker build -t $ACR_NAME/crudkub-server:latest .
# # Build and push Docker images
docker push $ACR_NAME/crudkub-server:latest

# az acr import \
#       --name $ACR_NAME \
#       --source docker.io/library/crudkub-server:latest \
#       --image crudkub-server:latest

#########################################################################################################################
#
#########################################################################################################################

#########################################################################################################################
#Auto deploy and configure Azure Kubernetes Service (AKS)
#########################################################################################################################

# terraform apply \
#     -target=azurerm_kubernetes_cluster.main \
#     -target=azurerm_role_assignment.aks_acr_pull \
#     -auto-approve



    
#########################################################################################################################
#
#########################################################################################################################


#########################################################################################################################
#Auto deploy and configure PostgreSQL database for AKS
#########################################################################################################################

kubectl create secret generic postgres-secret \
  --from-literal=PGHOST=$PSQL_HOST \
  --from-literal=PGUSER=$PSQL_USER \
  --from-literal=PGPASSWORD=$PSQSL_PSWD \
  --from-literal=PGDATABASE='postgres' \
  --from-literal=PGPORT='5432' \
  --from-literal=PGSSLMODE='require'

kubectl apply -f k8s

for file in k8s/*.yaml; do
  envsubst < "$file" | kubectl apply -f -
done
kubectl rollout restart deployment/crudkub-server

# PSQL_HOST=$(terraform output -raw postgresql_server_fqdn)
# PSQL_USER=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="azurerm_postgresql_flexible_server" and .name=="main") | .values.administrator_login')
# NEW_DB_NAME=$(terraform output -raw postgresql_database_name)

# psql "host=$PSQL_HOST port=5432 user=$PSQL_USER dbname=$NEW_DB_NAME sslmode=require"

# \c $NEW_DB_NAME

# CREATE TABLE todos (
#     id SERIAL PRIMARY KEY,
#     title VARCHAR(255) NOT NULL,
#     completed BOOLEAN DEFAULT false,
#     created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
#     updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
# );

#########################################################################################################################
#
#########################################################################################################################