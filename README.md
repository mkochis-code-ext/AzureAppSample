# Azure App Sample - Terraform Infrastructure

> **Disclaimer:** This repository is provided purely as a demonstration of these workflows. You are free to use, modify, and adapt the code as you see fit; however, it is offered as-is with no warranty or support of any kind. Use it at your own risk. This is not production-ready code — it should be reviewed, understood, and rewritten to suit your own environment before any real-world use.

This Terraform configuration uses a three-layer modular architecture to deploy a secure Azure web application infrastructure.

## 📁 Folder Structure

```
terraform/
├── environments/
│   └── dev/
│       ├── main.tf                    # Environment-specific configuration
│       ├── variables.tf               # Environment variables
│       ├── outputs.tf                 # Environment outputs
│       └── terraform.tfvars.example   # Example configuration
├── project/
│   ├── main.tf                        # Project-level orchestration
│   ├── variables.tf                   # Project variables
│   └── outputs.tf                     # Project outputs
└── modules/
    └── azurerm/
        ├── resource_group/            # Resource Group module
        ├── virtual_network/           # Virtual Network module
        ├── subnet/                    # Subnet module
        ├── private_dns/               # Private DNS Zone module
        ├── private_endpoint/          # Private Endpoint module
        ├── app_service/               # App Service module
        ├── application_gateway/       # Application Gateway module
        └── network_security_group/    # NSG module
```

## 🏗️ Architecture Overview

### Three-Layer Design

1. **Environments Layer** (`environments/dev/`)
   - Terraform and provider version constraints
   - Generates random suffix for resource uniqueness
   - Sets environment-specific configuration
   - Calls the project module

2. **Project Layer** (`project/`)
   - Orchestrates all infrastructure components
   - Builds resource names following naming conventions
   - Calls individual resource modules
   - Manages dependencies between resources

3. **Modules Layer** (`modules/azurerm/`)
   - Reusable, single-purpose resource modules
   - Standardized inputs (name, resource_group_name, location, tags)
   - Consistent outputs (id, name, resource-specific outputs)

### Deployed Resources

- **Resource Group**: Container for all resources
- **Virtual Network**: 10.0.0.0/16 with three subnets
  - App Service Integration: 10.0.1.0/24
  - Application Gateway: 10.0.2.0/24
  - Private Endpoints: 10.0.3.0/24
- **App Service**: Linux-based, VNet integrated (not publicly accessible)
- **Application Gateway**: Public entry point with health probes
- **Network Security Group**: Controls traffic to App Service

## 🔒 Security Features

✅ **App Service is NOT publicly accessible** - Only through Application Gateway  
✅ **VNet Integration** - App Service integrated into virtual network  
✅ **HTTPS enforced** - App Service configured for HTTPS only  
✅ **TLS 1.2 minimum** - Modern encryption standards enforced  
✅ **Network Security Groups** - Traffic filtering at subnet level  

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Active Azure subscription with appropriate permissions

### Deployment Steps

1. **Authenticate with Azure**

```bash
az login
az account set --subscription "<your-subscription-id>"
```

2. **Navigate to Environment Directory**

```bash
cd terraform/environments/dev
```

3. **Configure Variables**

Copy and customize the tfvars file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**⚠️ IMPORTANT**: Edit `terraform.tfvars` and set secure credentials:


4. **Initialize Terraform**

```bash
terraform init
```

5. **Review the Deployment Plan**

```bash
terraform plan
```

6. **Deploy Infrastructure**

```bash
terraform apply
```

Type `yes` when prompted.

7. **Access Application**

After deployment (15-20 minutes), get the public IP:

```bash
terraform output application_gateway_url
```

Visit: `http://<application-gateway-ip>`

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment_prefix` | Environment name | `dev` |
| `workload` | Workload identifier | `webapp` |
| `location` | Azure region | `eastus` |
| `data_location` | Data residency region | `""` (uses location) |
| `vnet_address_space` | VNet CIDR | `10.0.0.0/16` |
| `app_service_sku` | App Service SKU | `B1` |
| `appgw_sku_name` | App Gateway SKU | `Standard_v2` |

### Resource Naming Convention

Resources follow: `<type>-<workload>-<environment>-<suffix>`

Examples:
- Resource Group: `rg-webapp-dev-a1b`
- App Service: `app-webapp-dev-a1b`
- VNet: `vnet-webapp-dev-a1b`

## 📤 Outputs

After deployment, these outputs are available:

- `resource_group_name` - Resource group name
- `app_service_name` - App Service name
- `application_gateway_url` - Application access URL
- `application_gateway_public_ip` - Public IP address
- `virtual_network_name` - VNet name

View all outputs:

```bash
terraform output
```

## 🌐 Network Architecture

```
Internet
   │
   ▼
Application Gateway (Public: 10.0.2.0/24)
   │ HTTPS
   ▼
App Service (Private: 10.0.1.0/24)
   │ VNet Integration
   ▼
Private Endpoint (10.0.3.0/24)


## 🔧 Module Usage

Each module follows a consistent pattern:

### Module Inputs
```hcl
module "example" {
  source = "../modules/azurerm/<resource>"
  
  name                = "resource-name"
  resource_group_name = "rg-name"
  location            = "eastus"
  tags                = { Environment = "dev" }
  
  # Resource-specific properties
}
```

### Module Outputs
```hcl
output "id" { value = azurerm_<resource>.main.id }
output "name" { value = azurerm_<resource>.main.name }
# Additional resource-specific outputs
```

## 🎯 Next Steps

1. **Deploy Application Code**
   - Use Azure CLI or CI/CD pipeline
   - Deploy to the App Service

2. **Configure SSL/TLS**
   - Add SSL certificate to Application Gateway
   - Configure custom domain

3. **Set Up Monitoring**
   - Enable Application Insights
   - Configure Azure Monitor alerts

4. **Implement CI/CD**
   - GitHub Actions or Azure DevOps
   - Automated deployments

5. **Enhance Security**
   - Enable WAF on Application Gateway
   - Configure Azure Key Vault for secrets
   - Implement managed identities

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform/environments/dev
terraform destroy
```

Type `yes` to confirm. This will remove all resources in the resource group.

## 🐛 Troubleshooting

### Common Issues

**App Service can't connect to SQL**
- Verify Private Endpoint is healthy
- Check DNS resolution: `nslookup <sql-server>.database.windows.net`
- Ensure `WEBSITE_VNET_ROUTE_ALL=1` is set

**Application Gateway health probe failing**
- Check App Service is running
- Verify backend pool FQDN
- Review probe configuration (protocol, path, timeout)

**Terraform init fails**
- Verify Terraform version >= 1.0
- Check internet connectivity
- Clear `.terraform` directory and retry

**Deployment timeout**
- Application Gateway takes 15-20 minutes
- Be patient, monitor Azure Portal for progress


## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Application Gateway Documentation](https://docs.microsoft.com/azure/application-gateway/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
