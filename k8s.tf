module "ssh-key" {
  source         = "./ssh-key"
  public_ssh_key = var.public_ssh_key == "" ? "" : var.public_ssh_key
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.virtual_network}"
  resource_group_name  = "${var.ng_resource_group}"
}

data "azurerm_resource_group" "k8s" {
    name            = "${var.aks_resource_group_name}"
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length         = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${data.azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}

/*resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${data.azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}*/

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.aks_cluster_name}"
    location            = "${data.azurerm_resource_group.k8s.location}"
    resource_group_name = "${data.azurerm_resource_group.k8s.name}"
    dns_prefix          = "${var.dns_prefix}"
    kubernetes_version  = "${var.kubernetes_version}"

    network_profile {
        network_plugin = "azure"
        #load_balancer_sku = "standard"
    }

    linux_profile {
        admin_username = "${var.VM_username}"

        ssh_key {
            key_data = "${module.ssh-key.public_ssh_key}"
        }
    }

    windows_profile {
        admin_username = "${var.VM_username}"
        admin_password = "${var.VM_password}"
    }

    dynamic "agent_pool_profile" {
    for_each = var.agent_pools
    content {
      name                  = agent_pool_profile.value.npool_name
      count                 = agent_pool_profile.value.count
      vm_size               = agent_pool_profile.value.vm_size
      os_type               = agent_pool_profile.value.os_type
      os_disk_size_gb       = agent_pool_profile.value.os_disk_size_gb
      type                  = "VirtualMachineScaleSets"
      #availability_zones    = agent_pool_profile.value.availability_zones
      enable_auto_scaling   = agent_pool_profile.value.enable_auto_scaling
      min_count             = agent_pool_profile.value.min_count
      max_count             = agent_pool_profile.value.max_count
      #max_pods             = agent_pool_profile.value.max_pods

      # Required for advanced networking
      vnet_subnet_id        = "${data.azurerm_subnet.subnet.id}"
    }
  }
    /* agent_pool_profile {
        name                        = "wpool"
        type                        = "VirtualMachineScaleSets"
        #enable_cluster_autoscaler  = "true"
        enable_auto_scaling         = "${var.VirtualMachineScaleSets}" 
        min_count                   = "1"
        max_count                   = "3"
        count                       = "${var.agent_count}"
        vm_size                     = "${var.virtual_machine_size}"
        os_type                     = "${var.os_type}"
        os_disk_size_gb             = "${var.os_disk_size_gb}"
        vnet_subnet_id              = "${data.azurerm_subnet.subnet.id}"
    } */

    role_based_access_control {
        /*azure_active_directory {
            client_app_id       = "${var.client_id}"
            server_app_id       = "${var.client_id}"
            tenant_id           = "${var.tenant_id}"
            server_app_secret   = "${var.client_secret}"
        }*/
        enabled     = "true"
    }
    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    addon_profile {  
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
        }
    }

    tags = {
        BUC               = "${var.BUC}"
        SNOW              = "${var.SNOW}"
        SPONSOR           = "${var.SPONSOR}"
        SolutionCentralID = "${var.SolutionCentralID}"
    }
}