# Request Flow: Public Internet to App Service

This document details the network traffic flow from the public internet to the Azure App Service, as defined in the Terraform configuration.

## High-Level Overview

The architecture uses an **Application Gateway** as the single entry point for public traffic. The **App Service** is completely isolated from the public internet and is only accessible via a **Private Endpoint**.

**Flow Summary:**
`User` -> `App Gateway (Public IP)` -> `Private Link` -> `App Service`

---

## Step-by-Step Request Flow

### 1. Public Internet to Application Gateway
*   **Source**: Public Internet client (browser, API client).
*   **Destination**: Azure Application Gateway Public IP.
*   **Protocol/Port**: HTTP (80) or HTTPS (443).
*   **Mechanism**:
    *   The Application Gateway has a Standard SKU Public IP assigned.
    *   **Network Security Group (NSG)**: The `nsg-appgw` applied to the `snet-appgw` subnet explicitly allows inbound traffic on ports 80 and 443 from `*` (Any).

### 2. Application Gateway Processing
*   **Listener**:
    *   **Port 80**: A listener captures HTTP traffic and immediately redirects it to HTTPS (Port 443) using a permanent redirect configuration.
    *   **Port 443**: A listener captures HTTPS traffic and terminates the SSL connection using the configured SSL certificate.
*   **Routing**:
    *   The request is processed by the `https-settings` backend HTTP settings.
    *   **Backend Pool**: The backend pool is configured with the FQDN of the App Service (e.g., `app-workload-dev-xyz.azurewebsites.net`).

### 3. DNS Resolution (Critical Step)
*   **Context**: The Application Gateway resides in the Virtual Network (`vnet-workload-dev-xyz`).
*   **Mechanism**:
    *   The VNet is linked to a **Private DNS Zone** named `privatelink.azurewebsites.net`.
    *   When the Application Gateway tries to resolve the App Service's FQDN, the Private DNS Zone intercepts the request.
    *   Instead of returning the public IP of the App Service, it returns the **Private IP** address associated with the App Service's Private Endpoint (located in `snet-private-endpoints`).

### 4. Application Gateway to App Service
*   **Source**: Application Gateway instance (Private IP in `snet-appgw`).
*   **Destination**: App Service Private Endpoint (Private IP in `snet-private-endpoints`).
*   **Protocol/Port**: HTTPS (443).
*   **Mechanism**:
    *   The Application Gateway initiates a new connection to the backend.
    *   Traffic flows entirely within the Azure Virtual Network backbone.
    *   **App Service Configuration**: The App Service has `public_network_access_enabled = false`, ensuring it rejects any traffic not coming through the Private Endpoint.
    *   **Host Header**: The `pick_host_name_from_backend_address = true` setting ensures the Host header matches the App Service FQDN, which is required for the App Service to accept the request.

---

## Component Configuration Details

### Application Gateway
*   **Subnet**: `snet-appgw`
*   **Public Access**: Yes (Static Public IP).
*   **Backend Communication**: Uses the backend's FQDN, which resolves to a private IP.

### App Service
*   **Subnet Integration**: `snet-app-integration` (Used for *outbound* traffic from the app to other Azure resources).
*   **Public Access**: **Disabled**.
*   **Private Access**: Enabled via Private Endpoint in `snet-private-endpoints`.

### Network Security Groups (NSG)
*   **`nsg-appgw`**:
    *   Allows Inbound 80/443 from Internet.
    *   Allows Inbound 65200-65535 for Gateway Manager (Azure Infrastructure).
*   **`nsg-app`**:
    *   Applied to `snet-app-integration`.
    *   *Note*: This NSG primarily filters traffic for the integration subnet. Since inbound traffic arrives via the Private Endpoint (which bypasses this subnet's NSG by default), the rules here are secondary to the Private Endpoint restriction.

### Private DNS
*   **Zone**: `privatelink.azurewebsites.net`
*   **Link**: Linked to the main Virtual Network.
*   **Record**: Maps the App Service name to the Private Endpoint IP.
