function Set-AzDnsAsCodeMultiConfig
{
    <#
    .SYNOPSIS
        Manage your Azure DNS Zone via API based on JSON config

    .DESCRIPTION
        Get bearer token from a Azure AD Application
        Send Controlls via Webrequest to Azure API to manange DNS Zone

    .PARAMETER ZoneConfigPath
        Path to DNS Zone config file
    
    .PARAMETER SubscriptionID
        Set Subscription ID

    .PARAMETER TenantID
        Set Tenant ID

    .PARAMETER ResourceGroup
        Set ResourceGroup NAME (NOT ID!!!)

    .EXAMPLE
        PS C:\> Set-AzDnsAsCodeMultiConfig -ZoneConfigPath .\

        Setup a complete DNS Zone
    #>

    [CmdletBinding()]
    param (
        [Parameter (Mandatory=$true)][String]$ZoneConfigPath,

        [Parameter (Mandatory=$true)][String]$SubscriptionID,
        
        [Parameter (Mandatory=$true)][String]$TenantId,
        
        [Parameter (Mandatory=$true)][String]$ResourceGroup
        
    )

    $json = Get-Content $ZoneConfigPath | convertfrom-json


    foreach ($DNSZone in $json.psobject.Properties) {
        $DNSZone = $DNSZone.Name
        Write-Output "Set Entries for = Domain: $DNSZone"
        
        #Test is Domain exist

        foreach ($type in $json.($DNSZone).psobject.Properties) {
            $Type = $type.Name;
            Write-Output "--Create Entries for Type = $Type"
    
            foreach ($Domain in $json.$DNSZone.($type).psobject.Properties) {
                $Domain = $Domain.Name
                Write-Output "----Create Entries for = $Domain"
                $body = $json.$DNSZone.($type).$Domain | ConvertTo-Json -Depth 10
                $TTL = $json.$DNSZone.($type).$Domain.Properties.TTL
                $params = @{
                    'Method' = 'PUT'
                    'Type' = $type
                    'DNSZone' = $DNSZone
                    'Domain' = $Domain
                    'TTL' = $TTL
                    'body' = $body
                    'ApiVersion' = $script:APIversion
                    'SubscriptionId' = $SubscriptionID
                    'TenantId' = $TenantId
                    'ResourceGroup' = $ResourceGroup
                }
                Set-AzDnsAsCodeConfig @params
            }
        }
        Write-Output "---------------------------------------------------------------"
    }
}
