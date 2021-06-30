function New-AzDnsAsCodeZone
{
    <#
    .SYNOPSIS
        Execute a request to create a new Azure DNS Zone
    
    .DESCRIPTION
        Execute a request to create a new Azure DNS Zone
    
    .PARAMETER DNSZoneName
        Which rest method to use.
        Defaults to PUT

    .PARAMETER MetaData
        Set MetaData
        
    .PARAMETER SubscriptionID
        Set Subscription ID

    .PARAMETER TenantID
        Set Tenant ID

    .PARAMETER ResourceGroup
        Set ResourceGroup NAME (NOT ID!!!)
        
    .EXAMPLE
        PS C:\> New-AzDnsAsCodeZone -Name 'contoso.com' -RessourceGroupid '<RessourceGroupid>' -SubscriptionId '<SubscriptionId>'

        PS C:\> New-AzDnsAsCodeZone -Name 'contoso.com' -RessourceGroupid '<RessourceGroupid>' -SubscriptionId '<SubscriptionId>' -MetaData @{ 'Company'= 'consto' }

        Set up a new Zone in Azure DNS Service
    #>
    [CmdletBinding()]
	param (
        [Parameter (Mandatory=$true)][String]$DNSZoneName,

        [Parameter (Mandatory=$false)][Hashtable]$MetaData,

        [Parameter (Mandatory=$true)][String]$SubscriptionID,
        
        [Parameter (Mandatory=$true)][String]$TenantId,
        
        [Parameter (Mandatory=$true)][String]$ResourceGroup
	)
    $ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
    $body = Get-Content $ScriptDir\internal\configurations\newzone.json #| ConvertFrom-Json
    <# MetaData
    If ($Null -eq $MetaData) {
        #$body.tags.psobject.properties.Remove('key1')
        $body.PSObject.Properties.Remove('tags')
    }
    else {
        $body.tags = $MetaData
    }#>
    #$body | ConvertTo-Json -Depth 10

    $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$($DNSZoneName)?api-version=$($script:APIversion)"

    Write-Output "Create DNS Zone -> $($DNSZoneName)"

    $response = AzAPICall -uri $Uri -Method PUT -currentTask "Creating new DNSZone $($DNSZoneName)" -body $body -listenOn Content
###Todo check if Zone is already exist with (Request Header IF-MATCH)
    $response | Select-Object name, `
    @{Name = "maxNumberOfRecordSets"; Expression = {"$($_.properties.maxNumberOfRecordSets)"}}, `
    @{Name = "NameServer"; Expression = {"$($_.properties.nameServers)"}} | Format-Table -AutoSize
    
}
