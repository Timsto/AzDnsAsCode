function Get-AzDnsAsCodeZoneConfig
{ 
    <#
    .SYNOPSIS
        Execute a request against the Azure Management Api to set DNS Entries
    
    .DESCRIPTION
        Execute a request against the Azure Management Api to set DNS Entries
    
    .EXAMPLE
        PS C:\> Get-AzDnsAsCodeZoneConfig -Method Get -DNSZone contoso.com -Domain api 
        PS C:\> Get-AzDnsAsCodeZoneConfig -Method Get -DNSZone contoso.com -Type A
    #>

    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter (Mandatory=$true)][ValidateSet('GET')][string]$Method,
        [Parameter (Mandatory=$false)][ValidateSet('A','AAAA','CNAME','MX','NS','SOA','SRV','TXT','PTR')][string]$Type,
        [Parameter (Mandatory=$true)][ValidatePattern("^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$")]$DNSZone,
        [Parameter (Mandatory=$false)][ValidatePattern("(^@)|\w+")][string]$Domain,
        # Azure required Parameters
        [Parameter (Mandatory=$false)][String]$ApiVersion = '2018-05-01',
        [Parameter (Mandatory=$true)][String]$SubscriptionID = '',
        [Parameter (Mandatory=$true)][String]$TenantId = '',
        [Parameter (Mandatory=$true)][String]$ResourceGroup = '' 
    )


    #region URL 
    if ($type -and $Domain) { 
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$DNSZone/$($Type)/$($Domain)?api-version=$APIversion"
    }
    elseif ($Type) { 
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$DNSZone/$($Type)?api-version=$APIversion"
    }
    else { 
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$DNSZone/all?api-version=$APIversion"
    }
    #endregion URL
    
    #region  API Call
$uri
        $response = AzAPICall -uri $uri -method Get -listenOn Content
        "---------------------------------------------------------------------------------------------------"
        "Response -> "
    #endregion API Call  
    #region Output
    if ($response.Count) { 
    "Anzahl Records: " + $response.value.Count    
        $output = $response.value | Select-Object name, `
        @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
        @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
        @{Name = "Properties"; Expression = { [string]($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
        @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize
    } 
    else {
        "Anzahl Records: 1"
         $output = $response | Select-Object name, `
         @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
         @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
         @{Name = "Properties"; Expression = { [string]($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
         @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize 
    }
        return $output
    #endregion Output
}
