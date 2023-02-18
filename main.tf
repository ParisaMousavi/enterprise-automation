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
  content                 = templatefile("${path.module}/powershellworkflow/script.ps1", {"RUNBOOK_NAME"= "MyFirstPSWorkflow"})
  # publish_content_link = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}