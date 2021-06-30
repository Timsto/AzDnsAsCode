function Test-AzDnsAsCodeDomain
{
    <#
    .SYNOPSIS
        Test if DNSZone exist in Azure DNS Service
    
    .DESCRIPTION
        Test if DNSZone exist in Azure DNS Service
    
    .EXAMPLE
        PS C:\> Test-AzDnsAsCodeDomain -Name contoso.com -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup

        Test if DNSZone exist in Azure DNS Service
    #>
    [CmdletBinding()]
    param (
        [Parameter (Mandatory=$true)][String]$Name,

        [Parameter (Mandatory=$true)][String]$SubscriptionID,

        [Parameter (Mandatory=$true)][String]$ResourceGroup
    )
    
    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$($Name)?api-version=$($script:APIversion)"

    try {
        AzAPICall -uri $uri -method Get -currentTask "Check if $($Name) exist" -listenOn Content | Out-Null
        return $true
    }
    catch {
        return $false
    }
}