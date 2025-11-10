# Infraestructura - Ecommerce Microservices

Este directorio contiene la configuración de infraestructura como código (IaC) para desplegar los microservicios de ecommerce en Azure Kubernetes Service (AKS).

## 📁 Estructura

```
infra/
├── terraform/          # Configuración de Terraform para AKS
│   ├── main.tf        # Recursos principales (AKS, Resource Group)
│   ├── variables.tf   # Variables configurables
│   ├── outputs.tf     # Outputs de Terraform
│   └── terraform.tfvars  # Valores de variables
└── k8s/               # Manifiestos de Kubernetes
    ├── zipkin/        # Zipkin (distributed tracing)
    ├── service-discovery/  # Eureka Server
    ├── cloud-config/  # Spring Cloud Config
    ├── api-gateway/   # API Gateway
    ├── user-service/  # User Service
    ├── order-service/ # Order Service
    └── product-service/  # Product Service
```

## 🚀 Prerequisitos

### 1. Herramientas Necesarias

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (v2.0+)
- [Terraform](https://www.terraform.io/downloads) (v1.0+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.20+)

### 2. Autenticación en Azure

```powershell
# Login en Azure
az login

# Verificar la suscripción activa
az account show

# (Opcional) Cambiar de suscripción
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Crear Service Principal para Terraform

```powershell
# Crear Service Principal
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"

# Guarda los valores retornados:
# - appId (AZURE_CLIENT_ID)
# - password (AZURE_CLIENT_SECRET)
# - tenant (AZURE_TENANT_ID)
```

### 4. Configurar Variables de Entorno

```powershell
# PowerShell
$env:ARM_CLIENT_ID="your-client-id"
$env:ARM_CLIENT_SECRET="your-client-secret"
$env:ARM_SUBSCRIPTION_ID="your-subscription-id"
$env:ARM_TENANT_ID="your-tenant-id"
```

## 📦 Despliegue de Infraestructura

### Paso 1: Inicializar Terraform

```powershell
cd infra/terraform
terraform init
```

### Paso 2: Planificar el Despliegue

```powershell
terraform plan
```

### Paso 3: Aplicar la Configuración

```powershell
terraform apply
```

### Paso 4: Obtener Credenciales de AKS

```powershell
# Obtener kubeconfig
az aks get-credentials --resource-group ecommerce-microservices-rg --name ecommerce-aks-cluster

# Verificar conexión
kubectl get nodes
```

## ☸️ Despliegue de Aplicaciones en Kubernetes

### Desplegar todos los servicios

```powershell
cd infra/k8s

# Desplegar servicios de infraestructura primero
kubectl apply -f zipkin/
kubectl apply -f service-discovery/
kubectl apply -f cloud-config/

# Esperar a que estén ready
kubectl wait --for=condition=ready pod -l app=zipkin --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-discovery --timeout=120s
kubectl wait --for=condition=ready pod -l app=cloud-config --timeout=120s

# Desplegar servicios de negocio
kubectl apply -f api-gateway/
kubectl apply -f user-service/
kubectl apply -f order-service/
kubectl apply -f product-service/
```

### Verificar Despliegue

```powershell
# Ver todos los pods
kubectl get pods

# Ver todos los servicios
kubectl get services

# Ver logs de un pod específico
kubectl logs -f <pod-name>

# Describir un pod
kubectl describe pod <pod-name>
```

## 🔧 Configuración

### Variables de Terraform (`terraform.tfvars`)

- `location`: Región de Azure (default: "eastus")
- `node_count`: Número inicial de nodos (default: 2)
- `vm_size`: Tamaño de las VMs (default: "Standard_D2s_v3")
- `create_acr`: Crear Azure Container Registry (default: false, usa Docker Hub)

### Regiones Recomendadas

- `eastus` - Estados Unidos Este
- `westeurope` - Europa Occidental
- `southcentralus` - Estados Unidos Centro Sur

## 🧹 Limpieza

### Eliminar Recursos de Kubernetes

```powershell
kubectl delete -f infra/k8s/ --recursive
```

### Destruir Infraestructura de Azure

```powershell
cd infra/terraform
terraform destroy
```

## 📊 Monitoreo y Troubleshooting

### Acceder a Zipkin (Distributed Tracing)

```powershell
kubectl port-forward service/zipkin 9411:9411
# Abrir http://localhost:9411
```

### Acceder a Eureka (Service Discovery)

```powershell
kubectl port-forward service/service-discovery 8761:8761
# Abrir http://localhost:8761
```

### Ver logs en tiempo real

```powershell
kubectl logs -f deployment/api-gateway
```

## 🔐 Secrets de Kubernetes

Los secrets deben ser creados antes de desplegar las aplicaciones:

```powershell
# Ejemplo: crear secret para Docker Hub (si es necesario)
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD \
  --docker-email=YOUR_EMAIL
```

## 📝 Notas Importantes

1. **Costos**: Los recursos de AKS generan costos. Revisa [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
2. **Auto-scaling**: El cluster está configurado para auto-escalar entre 1-5 nodos
3. **Docker Hub**: Por defecto usa imágenes públicas de Docker Hub. Si son privadas, configura imagePullSecrets
4. **Eureka vs K8s DNS**: Actualmente usa Eureka para service discovery, pero K8s DNS también está disponible

## 🆘 Soporte

Para problemas o preguntas:

1. Revisar logs: `kubectl logs <pod-name>`
2. Describir recursos: `kubectl describe <resource-type> <resource-name>`
3. Verificar eventos: `kubectl get events --sort-by='.lastTimestamp'`

---

## 🗄️ Backend Remoto con Azure Storage (Estado de Terraform)

Para almacenar el estado de Terraform de forma centralizada y habilitar el trabajo en equipo, se recomienda usar un backend remoto en Azure Storage:

1. Crear un **Resource Group** (si no existe):

   ```powershell
   az group create --name tfstate-rg --location eastus2
   ```

2. Crear la **cuenta de almacenamiento** (usa una región permitida por las políticas de tu suscripción):

   ```powershell
   az storage account create --name <storageAccountName> `
     --sku Standard_LRS --resource-group tfstate-rg `
     --allow-blob-public-access false --https-only true `
     --min-tls-version TLS1_2 --location eastus2
   ```

3. Obtener la **clave de la cuenta** y crear el contenedor del estado:

   ```powershell
   $ACCOUNT_KEY = (az storage account keys list `
       --resource-group tfstate-rg `
       --account-name <storageAccountName> `
       --query "[0].value" -o tsv)

   az storage container create --name tfstate `
       --account-name <storageAccountName> `
       --account-key $ACCOUNT_KEY
   ```

4. Configurar el archivo `infra/terraform/backend.tf`:

   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "tfstate-rg"
       storage_account_name = "<storageAccountName>"
       container_name       = "tfstate"
       key                  = "dev.terraform.tfstate" # Cambiar por el workspace/entorno
     }
   }
   ```

5. Inicializar Terraform con el backend remoto:

   ```powershell
   cd infra/terraform
   terraform init -backend-config="key=dev.terraform.tfstate"
   ```

---

## 🏗️ Estructura Multi-entorno

Para gestionar múltiples entornos (dev, stage, prod) crea carpetas dedicadas en `infra/environments` y un workspace de Terraform por cada uno:

```
infra/
└── environments/
    ├── dev/
    │   └── terraform.tfvars
    ├── stage/
    │   └── terraform.tfvars
    └── prod/
        └── terraform.tfvars
```

Ejemplo de `terraform.tfvars` para **dev**:

```hcl
location        = "eastus2"   # Región permitida
environment     = "dev"
resource_suffix = "dev"       # Se añade a nombres de recursos (aks, acr, etc.)
create_acr      = true         # Opcional
```

Luego:

```powershell
# Seleccionar o crear workspace
aZss ö terraform workspace new dev   # Solo la primera vez
terraform workspace select dev

terraform init -backend-config="key=dev.terraform.tfstate"
terraform plan -out=tfplan-dev
terraform apply tfplan-dev
```

---

## 🌍 Manejo de Políticas de Región

Si tu suscripción aplica políticas de Azure que restringen regiones:

1. Lista las regiones permitidas:

   ```powershell
   az account list-locations -o table
   # o
   az policy state list --query "[].{policy:policyDefinitionName, status:complianceState, location:location}"
   ```

2. Actualiza la variable `location` en `terraform.tfvars` y en cualquier comando `az` para usar una región autorizada (por ejemplo `eastus2`).

3. Si cambias la región, modifica también los nombres de recursos que incluyan la región para evitar conflictos (p. ej. sufijo `dev`, `stage`, `prod`).


