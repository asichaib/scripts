Param
(
    [parameter(Mandatory=$false,ValueFromPipeline = $true)] 
    [Array]$KeyNames,
    [parameter(Mandatory=$false)] 
    [String]$ReportOutputPath,
    [parameter(Mandatory=$false)] 
    [String]$YouLogoHereURLString
)
 
[switch]$AutoKeyName =$false
$m = Get-Module -List ReportHTML
if(!$m) {"Can't locate module ReportHTML.  Use Install-module ReportHTML";break}
else {import-module reporthtml}
 
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount}
 
$RGs = Get-AzureRmResourceGroup
if ($KeyNames.count -eq 0) 
{
    [switch]$AutoKeyName =$true
    $KeyNames = (($rgs.Tags.keys) | select -Unique)
}
 
$SubscriptionRGs = @()
foreach ($RG in $RGs) 
{
 
    $myRG = [PSCustomObject]@{
        ResourceGroupName     = $RG.ResourceGroupName
        Location = $RG.Location
        Link    =  ("URL01" + "https" + "://" + "portal.azure.com/#resource" + $RG.ResourceId  +  "URL02" + ($RG.ResourceId.Split('/') | select -last 1) + "URL03" )
    }
 
    $i=0
    foreach ($KeyName in $KeyNames) 
    {
        if ($AutoKeyName)
        {
            $myRG | Add-Member -MemberType NoteProperty -Name ([string]$i + "_" + $keyname) -Value $rg.Tags.($KeyName)
            $i++
        }
        else
        {
            $myRG | Add-Member -MemberType NoteProperty -Name ($keyname) -Value $rg.Tags.($KeyName)
        }
    }
    $SubscriptionRGs += $myRG
}
 
 
$rpt = @()
if ($YouLogoHereURLString -ne $null)
{
    $rpt += Get-HTMLOpenPage -TitleText "Azure Resource Groups" -LeftLogoString $YouLogoHereURLString -RightLogoString  ("https" + "://" + "azurefieldnotesblog.blob.core.windows.net/wp-ontent/2017/02/ReportHTML.png")
}
else
{
    $rpt += Get-HTMLOpenPage -TitleText "Azure Resource Groups"
}
 
    if (!$AutoKeyName) 
    {
        $Pie1 = $SubscriptionRGs| group $KeyNames[0]
        $Pie2 = $SubscriptionRGs| group $KeyNames[1]
 
        $Pie1Object = Get-HTMLPieChartObject -ColorScheme Random
        $Pie2Object = Get-HTMLPieChartObject -ColorScheme Generated
 
        $rpt += Get-HTMLContentOpen -HeaderText "Pie Charts"
               $rpt += Get-HTMLColumnOpen -ColumnNumber 1 -ColumnCount 2
                   $rpt += Get-HTMLPieChart -ChartObject $Pie1Object  -DataSet $Pie1
               $rpt += Get-HTMLColumnClose
               $rpt += Get-HTMLColumnOpen -ColumnNumber 2 -ColumnCount 2
                   $rpt += Get-HTMLPieChart -ChartObject $Pie2Object -DataSet $Pie2
               $rpt += Get-HTMLColumnClose
        $rpt += Get-HTMLContentclose
    }
 
    $rpt += Get-HTMLContentOpen -HeaderText "Complete List"
        $rpt += Get-HTMLContentdatatable -ArrayOfObjects ( $SubscriptionRGs)
    $rpt += Get-HTMLContentClose
 
$rpt += Get-HTMLClosePage 
 
if ($ReportOutputPath -ne $null)
{
    Save-HTMLReport -ShowReport -ReportContent $rpt -ReportName ResourceGroupTags
}
else
{
    Save-HTMLReport -ShowReport -ReportContent $rpt -ReportName ResourceGroupTags -ReportPath $ReportOutputPath
}