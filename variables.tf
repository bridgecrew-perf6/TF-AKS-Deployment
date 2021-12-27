variable "subscription_id" {
    description = "subscription_id where this AKS cluster needs to be created"
}

variable "client_id" {
    description = "Service Principal Client ID"
}

variable "client_secret" {
    description = "Service Principal Password"
}

variable "tenant_id" {
    description = "Service Principal Tenant ID"
}

variable "kubernetes_version" {
    description = "Kuberenete Version"
}

variable "VM_username" {
    description = "User ID accessing VMs(It is same for both windows and Linux) "
}

variable "VM_password" {
    description = "Password for accessing windows profile"
}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = ""
}

variable "dns_prefix" {
    description = "Client Specific short name and it will appended as prefix for MC RG"
}

variable "aks_resource_group_name" {
    description = "RG name, where you want to deploy this AKS"
}

variable "location" {
    default = "West US 2"
    description = "Location details this AKS and agentpool creates"
}

variable "log_analytics_workspace_name" {
    description = "log analytics workspace name"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
    default = "West US 2"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
    default = "PerNode"
}

variable "ng_resource_group" {
    description = "RG name of the VNET"
}

variable "virtual_network" {
    description = "VNET - Name"
}

variable "subnet_name" {
    description = "Subnet name where the agentpool create the requried resources"
}

variable "network_plugin" {
    default = "azure"
    description = "Network Plugin"
}

variable "BUC" {
    description = "BUC number"
}

variable "SPONSOR" {
    description = "Project Sponsor"
}

variable "SNOW" {
    description = "SNOW Number"
}

variable "SolutionCentralID" {
    description = "Product ID"
}

variable "service_cidr" {
    default = "10.0.0.0/16"
    description = "service cidr for AKS"
}

variable "dns_service_ip" {
    default = "10.0.0.10"
    description = "DNS service IP for AKS"
}

variable "docker_bridge_cidr"{
    default = "172.17.0.1/16"
    description = "Docker Bridge CIDR"
}

variable "aks_cluster_name" { 
    description = "AKS cluster name"
}

# Agent Pool relevant variables for multipool setup
variable "agent_pools" {
  #description = "(Optional) List of agent_pools profile for multiple node pools"
  type = list(object({
    npool_name                          = string
    count                               = number
    vm_size                             = string
    os_type                             = string
    os_disk_size_gb                     = number
    #max_pods                           = number
    enable_auto_scaling                 = bool
    min_count                           = number
    max_count                           = number
  }))

  default = [{
    npool_name                          = "<NP_Name>"
    count                               = <Initial_Count_of_worker_node>
    vm_size                             = "<VM_Size>"
    os_type                             = "Linux/Windows"
    os_disk_size_gb                     = "<OS_Disk_Size>"
    #max_pods                           = "30"
    enable_auto_scaling                 = "<true/false>"
    min_count                           = <Min_Count_WorkerNode>
    max_count                           = <Max_Count_WorkerNode>  
    },
   /* {
    npool_name                          = "npwin"
    count                               = 1
    vm_size                             = "Standard_D2s_v3"
    os_type                             = "Windows"
    os_disk_size_gb                     = "128"
    #max_pods                           = 30
    enable_auto_scaling                 = "true"``
    min_count                           = 1
    max_count                           = 5  
    }*/
    ]
}