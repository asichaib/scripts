#variables

$myPath = 'c:\armtemplate\'
$subscription = 'NAME_OF_YOUR_SUBSCRIPTION'
$basePath = $myPath + '\' + $subscription + '\'
$output = $basePath + 'output.txt'
$ErrorActionPreference="SilentlyContinue"
$location = "westeurope"

#Login 

Login-AzureRmAccount

# Start transcript  

Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $output -append

# Get your subscription and resources groups

Select-AzureRmSubscription -Subscription $subscription

# Create all resources with ARM templates

$arms = Get-ChildItem -Path $basePath -Filter *.json

foreach ($arm in $arms)
{
    New-AzureRmResourceGroup -Name $arm.BaseName -Location $location
    New-AzureRmResourceGroupDeployment -ResourceGroupName $arm.BaseName -TemplateFile $basepath$arm
}

Stop-Transcript
