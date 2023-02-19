workflow ${RUNBOOK_NAME}
{
Param(
    [string]$resourceGroup,
    [string[]]$VMs, 
    [string]$action 
)
#["VM1","VM2","VM3"]
#stop or start
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity
#Connect-AzAccount -Identity -AccountId <ClientId>

# set and store context
$AzureContext = Set-AzContext –SubscriptionId "<SubscriptionID>"   

# Start or stop VMs in parallel
if($action -eq "Start")
    {
        ForEach -Parallel ($vm in $VMs)
        {
            Start-AzVM -Name $vm -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext
        }
    }
elseif ($action -eq "Stop")
    {
        ForEach -Parallel ($vm in $VMs)
        {
            Stop-AzVM -Name $vm -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext -Force
        }
    }
else {
	    Write-Output "`r`n Action not allowed. Please enter 'stop' or 'start'."
	}
}