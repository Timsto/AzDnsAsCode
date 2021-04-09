function Remove-AzDnsAsCodeZone 
{ 
    <#
    .SYNOPSIS
        Execute a request to create a new Azure DNS Zone
    
    .DESCRIPTION
        Execute a request to create a new Azure DNS Zone
    

    .PARAMETER Name
        Which rest method to use.
        Defaults to PUT
    
    .EXAMPLE
        PS C:\> emove-AzDnsAsCodeZone -Name 'contoso.com' -RessourceGroupid '<RessourceGroupid>' -SubscriptionId '<SubscriptionId>'
    #>
    [CmdletBinding()]
	param (
        [Parameter (Mandatory=$true)][String]$Name,

        [Parameter (Mandatory=$true)][String]$SubscriptionID,
        
        [Parameter (Mandatory=$true)][String]$TenantId,
        
        [Parameter (Mandatory=$true)][String]$ResourceGroup,

        [Parameter (Mandatory=$false)][String]$ApiVersion = '2018-05-01'
	)

    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$($Name)?api-version=$APIversion"

    $response = AzAPICall -uri $uri -Method DELETE -currentTask "Remove DNSZone $($Name)"

    $response
}