az feature register --namespace Microsoft.HybridConnectivity --name hiddenPreviewAccess

az feature show --namespace Microsoft.HybridConnectivity --name hiddenPreviewAccess --query "properties" -o tsv

az provider register --namespace Microsoft.Kubernetes --wait 
az provider register --namespace Microsoft.KubernetesConfiguration --wait 
az provider register --namespace Microsoft.ExtendedLocation --wait
az provider register --namespace Microsoft.ResourceConnector --wait
az provider register --namespace Microsoft.HybridContainerService --wait
az provider register --namespace Microsoft.HybridConnectivity --wait

# Step 3: Install Azure CLI on the Azure VM
$ProgressPreference = 'SilentlyContinue'; 
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; 
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; 
rm .\AzureCLI.msi
Exit
# I used this link to install it on server. Because the command above didn't work.
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

# Step 4: Install Az CLI extensions on the Azure VM
$env:PATH += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin;"
az extension add -n k8s-extension --upgrade
az extension add -n customlocation --upgrade
az extension add -n arcappliance --version 0.2.29
az extension add -n hybridaks --upgrade

# Step 5: Install prerequisite PowerShell repositories
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted 
Install-PackageProvider -Name NuGet -Force  
Install-Module -Name PowershellGet -Force 
Exit

Install-Module -Name AksHci -Repository PSGallery -AcceptLicense -Force 
Exit

Install-Module -Name ArcHci -Repository PSGallery -AcceptLicense -Force 
Exit

Initialize-AksHciNode 
Exit

New-Item -Path "V:\" -Name "AKS-HCI" -ItemType "directory" -Force 
New-Item -Path "V:\AKS-HCI\" -Name "Images" -ItemType "directory" -Force 
New-Item -Path "V:\AKS-HCI\" -Name "WorkingDir" -ItemType "directory" -Force 
New-Item -Path "V:\AKS-HCI\" -Name "Config" -ItemType "directory" -Force 
Exit

# Step 6: Install the AKS on Windows Server management cluster
$vnet=New-AksHciNetworkSetting -Name "mgmt-vnet" -vSwitchName "InternalNAT" -gateway "192.168.0.1" -dnsservers "192.168.0.1" -ipaddressprefix "192.168.0.0/16" -k8snodeippoolstart "192.168.0.4" -k8snodeippoolend "192.168.0.10" -vipPoolStart "192.168.0.150" -vipPoolEnd "192.168.0.160"

Set-AksHciConfig -vnet $vnet -imageDir "V:\AKS-HCI\Images" -workingDir "V:\AKS-HCI\WorkingDir" -cloudConfigLocation "V:\AKS-HCI\Config" -cloudServiceIP "192.168.0.4"

$sub = <Azure subscription>
$rgName = <Azure resource group>

#Use device authentication to login to Azure. Follow the steps you see on the screen
Set-AksHciRegistration -SubscriptionId $sub -ResourceGroupName $rgName -UseDeviceAuthentication

Install-AksHci

# Validate AKS on Windows Server version
Get-AksHciVersion

# Step 7: Generate prerequisite YAML files needed to deploy Azure Arc Resource Bridge
$subscriptionId = <Azure subscription ID>
$resourceGroup = <Azure resource group>
$location=<Azure location. Can be "eastus", "westeurope", "westus3", or "southcentralus">

$workingDir = "V:\AKS-HCI\WorkDir"
$arcAppName="arc-resource-bridge"
$configFilePath= $workingDir + "\hci-appliance.yaml"
$arcExtnName = "aks-hybrid-ext"
$customLocationName="azurevm-customlocation"

New-ArcHciAksConfigFiles -subscriptionID $subscriptionId -location $location -resourceGroup $resourceGroup -resourceName $arcAppName -workDirectory $workingDir -vnetName "appliance-vnet" -vSwitchName "InternalNAT" -gateway "192.168.0.1" -dnsservers "192.168.0.1" -ipaddressprefix "192.168.0.0/16" -k8snodeippoolstart "192.168.0.11" -k8snodeippoolend "192.168.0.11" -controlPlaneIP "192.168.0.161"

# Step 8: Deploy Azure Arc Resource Bridge
az account set -s $subscriptionid
az arcappliance validate hci --config-file $configFilePath