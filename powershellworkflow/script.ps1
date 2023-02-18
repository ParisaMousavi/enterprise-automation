Workflow ${RUNBOOK_NAME}
{
    Parallel {
        Write-Output "Parallel"
        Get-Date
        Start-Sleep -s 3
        Get-Date
    }
   
   Write-Output " `r`n"
   Write-Output "Non-Parallel"
   Get-Date
   Start-Sleep -s 3
   Get-Date
}