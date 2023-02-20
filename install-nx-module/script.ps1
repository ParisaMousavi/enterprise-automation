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


$TenantId="0f912e8a-5f68-43ec-9075-1533aaa80442"
$Subscription="e75710b2-d656-4ee7-bc64-d1b371656208"

[string]$userName = '07cea789-5bb0-4381-9255-17b9f6909aad'
[string]$userPassword = 'iSS8Q~qOOnhto4Of.hyqoI5B5c9iceNZl6WdzdmF'

# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

[pscredential]$Credential = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential -Subscription $Subscription


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

