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
        PS C:\> Remove-AzDnsAsCodeZone -Name 'contoso.com' -RessourceGroupid '<RessourceGroupid>' -SubscriptionId '<SubscriptionId>'

        Remove a DNS Zone inside of Azure DNS Service
    #>
    [CmdletBinding()]
	param (
        [Parameter (Mandatory=$true)][String]$Name,

        [Parameter (Mandatory=$true)][String]$SubscriptionID,
        
        [Parameter (Mandatory=$true)][String]$TenantId,
        
        [Parameter (Mandatory=$true)][String]$ResourceGroup
	)

    #region Set uri
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$($Name)?api-version=$($script:APIversion)"
    #endregion Set uri
    
    #region send apicall
        Write-Output "Remove DNS Zone $($Name)"
        $response = AzAPICall -uri $uri -Method DELETE -currentTask "Remove DNSZone $($Name)"
    #endregion send apicall

    #region response
        Write-Output "---------------------------------------------------------------------------------------------------"
        Write-Output "Response ->"
        $response
    #region response
}
