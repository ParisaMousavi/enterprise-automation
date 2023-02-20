$resourceGroup = "sola-rg-aut-dev-weu"
$automationAccount = "sola-aa-aut-dev-weu"
$VM = "vm1"
$configurationName = "LinuxConfig"
$nodeConfigurationName0 = "LinuxConfig.IsNotPresent"
$nodeConfigurationName1 = "LinuxConfig.IsPresent"
$moduleName = "nx"
$moduleVersion = "1.0"

# # Sign in to your Azure subscription
# $sub = Get-AzSubscription -ErrorAction SilentlyContinue
# if(-not($sub))
# {
#     Connect-AzAccount
# }

# # If you have multiple subscriptions, set the one to use
# # Select-AzSubscription -SubscriptionId "<SUBSCRIPTIONID>"

# Install AzAutomation
# Install-Module -Name Az.Automation
# Install nx module
Write-Host "Install nx module"
New-AzAutomationModule  -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccount  -Name $moduleName  -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"

Write-Host "Verify Install nx module"
Get-AzAutomationModule `
    -ResourceGroupName $resourceGroup `
    -AutomationAccountName $automationAccount `
    -Name $moduleName

Write-Host "Import configuration to Azure Automation"
Import-AzAutomationDscConfiguration `
   -ResourceGroupName $resourceGroup `
   -AutomationAccountName $automationAccount `
   -SourcePath "C:\source\repos\enterprise-automation\dsc-configuration\LinuxConfig.ps1" `
   -Published

Write-Host "view the configuration from Automation account"
Get-AzAutomationDscConfiguration `
   -ResourceGroupName $resourceGroup `
   -AutomationAccountName $automationAccount `
   -Name $configurationName

# # Compile configuration in Azure Automation
# Start-AzAutomationDscCompilationJob `
#    -ResourceGroupName $resourceGroup `
#    -AutomationAccountName $automationAccount `
#    -ConfigurationName $configurationName

# # view the compilation job from your Automation account
# Get-AzAutomationDscCompilationJob `
#    -ResourceGroupName $resourceGroup `
#    -AutomationAccountName $automationAccount `
#    -ConfigurationName $configurationName

