#variables
$myPath = 'c:\armtemplate\'
$subscription = 'NAME_OF_YOUR_SUBSCRIPTION'
$basePath = $myPath + $subscription + '\'
$output = $basePath + 'output.txt'
$ErrorActionPreference="SilentlyContinue"

#Login 
Login-AzureRmAccount

# Start transcript 
 
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $output -append

# Get your subscription and resources groups
Get-AzureRmSubscription -SubscriptionName $subscription | Select-AzureRmSubscription 
$allresgroup = Get-AzureRmResourceGroup;

# Export all resources in ARM
foreach ($rg in $allresgroup)
{
    $rsname = $rg.ResourceGroupName 
    $fullpath = $basePath+$rsname+'.json'
    Export-AzureRmResourceGroup -ResourceGroupName $rsname -Path $fullpath -IncludeComments
    
}
 
Stop-Transcript
