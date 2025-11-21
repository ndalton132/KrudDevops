#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_menu() {
    echo ""
    echo "================================"
    echo "   Azure Deployment Manager"
    echo "================================"
    echo "1) Initial Setup (Deploy ACR)"
    echo "1A) Initial Setup (Deploy AKS plan)"
    echo "1B) Initial Setup (Deploy PSQL plan)"
    echo "1C) Initial Setup (Deploy everything)"
    echo "1D) Initial Setup (Deploy everything)"
    echo "2) Update ACR images only"
    echo "3) Deploy to Kubernetes only"
    echo "4) Update PostgreSQL only"
    echo "5) Full redeploy (destroy and recreate)"
    echo "6) Show current state"
    echo "7) Exit"
    echo "================================"
    read -p "Select option: " choice
    echo ""
}

function deploy-aks() {
    echo -e "${GREEN}🚀 Deploying AKS...${NC}"
    
    terraform init

    terraform plan \
        -target=azurerm_kubernetes_cluster.main \
        -target=azurerm_role_assignment.aks_acr_pull
    
    # terraform apply \
    #     -target=azurerm_kubernetes_cluster.main \
    #     -target=azurerm_role_assignment.aks_acr_pull \
    #     -auto-approve
    
    # echo -e "${GREEN}✅ AKS deployed!${NC}"
}

function initial_setup() {
    echo -e "${GREEN}🚀 Initial Setup - Deploying everything...${NC}"
    
    terraform init
    
    # Deploy in order
    echo "1/4 Deploying Resource Group..."
    terraform apply -target=azurerm_resource_group.main -auto-approve
    
    echo "2/4 Deploying Network & ACR..."
    terraform apply \
        -target=azurerm_virtual_network.main \
        -target=azurerm_subnet.aks \
        -target=azurerm_container_registry.main \
        -auto-approve
    
    echo "3/4 Deploying AKS..."
    terraform apply \
        -target=azurerm_kubernetes_cluster.main \
        -target=azurerm_role_assignment.aks_acr_pull \
        -auto-approve
    
    echo "4/4 Deploying PostgreSQL..."
    terraform apply \
        -target=azurerm_postgresql_flexible_server.main \
        -target=azurerm_postgresql_flexible_server_database.main \
        -auto-approve
    
    echo -e "${GREEN}✅ Initial setup complete!${NC}"
}

function update_images() {
    echo -e "${GREEN}📥 Updating container images...${NC}"
    
    # Get ACR name
    ACR_NAME=$(terraform output -raw acr_login_server)
    ACR_SHORT=${ACR_NAME%.azurecr.io}

    # Login to ACR
    az acr login --name $ACR_NAME

    docker tag crudkub-server $ACR_NAME/crudkub-server:latest

    # Build and push Docker images
    docker push $ACR_NAME/crudkub-server:latest
}

function deploy_kubernetes() {
    echo -e "${GREEN}☸️ Deploying to Kubernetes...${NC}"
    
    AKS_RG=$(terraform output -raw resource_group_name)
    AKS_NAME=$(terraform output -raw aks_cluster_name)
    
    echo "Getting AKS credentials..."
    az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME --overwrite-existing
    
    echo "Applying Kubernetes manifests..."
    kubectl apply -f k8s/
    
    echo "Restarting deployments to pull new images..."
    kubectl rollout restart deployment --all -n myapp 2>/dev/null || echo "No deployments to restart yet"
    
    echo -e "${GREEN}✅ Kubernetes updated!${NC}"
}

function update_postgres() {
    echo -e "${GREEN}🗄️ Updating PostgreSQL configuration...${NC}"
    
    terraform apply \
        -target=azurerm_postgresql_flexible_server.main \
        -target=azurerm_postgresql_flexible_server_database.main
    
    echo -e "${GREEN}✅ PostgreSQL updated!${NC}"
}

function full_redeploy() {
    echo -e "${RED}⚠️  WARNING: This will destroy and recreate everything!${NC}"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    
    if [ "$confirm" == "yes" ]; then
        terraform destroy -auto-approve
        initial_setup
    else
        echo "Cancelled."
    fi
}

function show_state() {
    echo -e "${GREEN}📊 Current Infrastructure State${NC}"
    echo ""
    echo "Resources managed by Terraform:"
    terraform state list
    echo ""
    echo "Outputs:"
    terraform output
}

# Main loop
while true; do
    print_menu
    
    case $choice in
        1) initial_setup ;;
        1B) deploy-aks ;;
        2) update_images ;;
        3) deploy_kubernetes ;;
        4) update_postgres ;;
        5) full_redeploy ;;
        6) show_state ;;
        7) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    read -p "Press Enter to continue..."
done