#!/bin/bash

#terraform init


#########################################################################################################################
#Auto deploy and configure Azure container registry (ACR) for AKS
#########################################################################################################################
# Deploy ACR
# terraform apply -target=azurerm_container_registry.main -target=azurerm_role_assignment.aks_acr_pull

# # # Get ACR name
# ACR_NAME=$(terraform output -raw acr_login_server)
# ACR_SHORT=${ACR_NAME%.azurecr.io}

# # Login to ACR
# az acr login --name $ACR_NAME

# docker tag crudkub-server $ACR_NAME/crudkub-server:latest

# # Build and push Docker images
# docker push $ACR_NAME/crudkub-server:latest

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

# PSQL_HOST=$(terraform output -raw postgresql_server_fqdn)
# PSQL_USER=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.type=="azurerm_postgresql_flexible_server" and .name=="main") | .values.administrator_login')
# NEW_DB_NAME=$(azurerm_postgresql_flexible_server_database.main.name)

# psql "host=$PSQL_HOST port=5432 user=$PSQL_USER dbname=postgres sslmode=require"

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