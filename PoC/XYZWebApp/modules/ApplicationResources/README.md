# MODULE: ApplicationResources

This module is designed for deploying a scalable and highly available application infrastructure in Azure. It provisions a set of resources critical for setting up a load-balanced application using Azure Virtual Machine Scale Sets (VMSS) and an Azure Load Balancer.

# ADD

This module does not include creating an Azure File Share and mapping it to VMs in the VMSS. If that functionality is required, it can be implemented by using additional Terraform resources. Below is an example Terraform configuration to create an Azure File Share and deploy an Azure VM extension to map the File Share to VMs in the VMSS.

### Terraform to Create Azure File Share

First, you'll need to create an Azure File Share within the Storage Account created by the module:

```hcl
resource "azurerm_storage_share" "file_share" {
  name                 = "myfileshare"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50  # Define the size of the file share in GB
}
```

### Terraform to Deploy Azure VM Extension for File Share Mapping

To map the Azure File Share to VMs in the VMSS, you can use the Azure VMSS extension resource.

```hcl
resource "azurerm_virtual_machine_scale_set_extension" "file_share_mapping" {
  name                         = "fileShareMapping"
  virtual_machine_scale_set_id = var.vmss_id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "mkdir -p /mnt/myfileshare && mount -t cifs ...
    }
SETTINGS
}
```