module "rg_name" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  location = var.location
  name     = module.rg_name.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "aut_name" {
  source             = "github.com/ParisaMousavi/az-naming//auto?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "auto_m_id_name" {
  source             = "github.com/ParisaMousavi/az-naming//mid?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "auto_m_id" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-managed-identity?ref=2022.10.24"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.auto_m_id_name.result
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}
# to allow them to stop and start a virtual machine
# https://learn.microsoft.com/en-us/azure/automation/learn/powershell-runbook-managed-identity#assign-permissions-to-managed-identities
resource "azurerm_role_assignment" "auto_m_id_role_1" {
  principal_id         = module.auto_m_id.principal_id
  scope                = module.resourcegroup.id
  role_definition_name = "DevTest Labs User"
  depends_on = [
    module.auto_m_id
  ]
}

module "automation_account" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source = "github.com/ParisaMousavi/az-auto-account?ref=main"
  depends_on = [
    module.auto_m_id
  ]
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aut_name.result
  sku_name            = "Basic"
  identityconfig = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [module.auto_m_id.id]
  }
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

# The same role for the automation account
# to allow them to stop and start a virtual machine
# https://learn.microsoft.com/en-us/azure/automation/learn/powershell-runbook-managed-identity#assign-permissions-to-managed-identities
resource "azurerm_role_assignment" "automation_account_role_1" {
  principal_id         = module.automation_account.principal_id
  scope                = module.resourcegroup.id
  role_definition_name = "DevTest Labs User"
  depends_on = [
    module.automation_account
  ]
}

resource "azurerm_role_assignment" "automation_account_role_2" {
  principal_id         = module.automation_account.principal_id
  scope                = module.resourcegroup.id
  role_definition_name = "Reader"
  depends_on = [
    module.automation_account
  ]
}

module "automation_account_runbook" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source = "github.com/ParisaMousavi/az-auto-runbook?ref=main"
  depends_on = [
    module.automation_account
  ]
  resource_group_name     = module.resourcegroup.name
  location                = module.resourcegroup.location
  name                    = "AzureVMTutorial"
  automation_account_name = module.automation_account.name
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"
  content                 = templatefile("${path.module}/powershell/start-stop-vms.ps1", { "AUTOMATION_ACCOUNT_NAME" = module.automation_account.name })
  # publish_content_link = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "automation_account_powershellworkflow" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source = "github.com/ParisaMousavi/az-auto-runbook?ref=main"
  depends_on = [
    module.automation_account
  ]
  resource_group_name     = module.resourcegroup.name
  location                = module.resourcegroup.location
  name                    = "MyFirstPSWorkflow"
  automation_account_name = module.automation_account.name
  description             = "This is an example PowerShellWorkflow runbook"
  runbook_type            = "PowerShellWorkflow"
  content                 = templatefile("${path.module}/powershellworkflow/script.ps1", { "RUNBOOK_NAME" = "MyFirstPSWorkflow" })
  # publish_content_link = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "automation_account_powershellworkflow_2" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source = "github.com/ParisaMousavi/az-auto-runbook?ref=main"
  depends_on = [
    module.automation_account
  ]
  resource_group_name     = module.resourcegroup.name
  location                = module.resourcegroup.location
  name                    = "MyFirstPSWorkflow_2"
  automation_account_name = module.automation_account.name
  description             = "This is an example PowerShellWorkflow runbook"
  runbook_type            = "PowerShellWorkflow"
  content                 = templatefile("${path.module}/powershellworkflow/script2.ps1", { "RUNBOOK_NAME" = "MyFirstPSWorkflow_2" })
  # publish_content_link = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = module.resourcegroup.location
  resource_group_name = module.resourcegroup.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.subnets["vm-linux"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  location            = module.resourcegroup.location
  resource_group_name = module.resourcegroup.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = "${var.name}-vm"
  location              = module.resourcegroup.location
  resource_group_name   = module.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.this.id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  # admin_password                  = "P@risa2023#0"
  disable_password_authentication = true
  allow_extension_operations      = true
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk { # disk name cannot be changed after creation
    name                 = "${var.name}-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = "/subscriptions/e75710b2-d656-4ee7-bc64-d1b371656208/resourceGroups/netexc-rg-projn-dev-network-weu/providers/Microsoft.Network/networkSecurityGroups/netexc-nsg-projn-dev-weu"
}

# output "dadada" {
#   value = file("~/.ssh/id_rsa.pub")
# }

# resource "azurerm_virtual_machine_extension" "example" {
#   name                 = "example"
#   virtual_machine_id   = azurerm_virtual_machine.main.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
#  {
#   "commandToExecute": "hostname && uptime"
#  }
# SETTINGS


#   tags = {
#     environment = "Production"
#   }
# }

# resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
#   name                       = "AADSSHLoginForLinux"
#   virtual_machine_id         = azurerm_linux_virtual_machine.main.id
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADSSHLoginForLinux"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
# }

# 1. Install powershell on ubuntu
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3


# Install az-module with powershell
# https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-9.4.0
# Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force


# Install modules in powershell
# https://www.powershellgallery.com/packages/PSCredentialTools/1.1.0

# 2.
# resource "azurerm_automation_dsc_configuration" "TestConfig" {
#   name                    = "TestConfig"
#   resource_group_name     = module.resourcegroup.name
#   automation_account_name = module.automation_account.name
#   location                = module.resourcegroup.location
#   content_embedded        = "configuration test {}"
#   log_verbose             = true
#   description             = "description TestConfig"
# }

resource "azurerm_automation_dsc_configuration" "TestConfig" {
  name                    = "TestConfig"
  resource_group_name     = module.resourcegroup.name
  automation_account_name = module.automation_account.name
  location                = module.resourcegroup.location
  # content_embedded        = templatefile("${path.module}/dsc-configuration/TestConfig-t.ps1", {"DSC_NAME" = "TestConfig"})
  content_embedded = <<BODY
configuration TestConfig 
{ 
    Node IsWebServer
    {
        WindowsFeature IIS {
            Ensure               = 'Present'
            Name                 = 'Web-Server'
            IncludeAllSubFeature = $true
        }
    }
    Node NotWebServer
    {
        WindowsFeature IIS {
            Ensure = 'Absent'
            Name   = 'Web-Server'
        }
    }
}
BODY
  log_verbose      = true
  description      = "description TestConfig"
}

# resource "null_resource" "non_interactive_call" {
#   depends_on = [module.automation_account]
#   triggers   = { always_run = timestamp() }
#   // The order of input values are important for bash
#   provisioner "local-exec" {
#     # command     = "chmod +x ${path.module}/non-interactive.sh ;${path.module}/non-interactive.sh ${module.resourcegroup.name} ${module.aks_name.result}"
#     command     = "PowerShell -file .\\install-nx-module\\script.ps1"
#   }
# }

# output "fdsfjshdjh" {
#   value = filebase64("${path.module}/dsc-configuration/TestConfig.ps1")
# }
