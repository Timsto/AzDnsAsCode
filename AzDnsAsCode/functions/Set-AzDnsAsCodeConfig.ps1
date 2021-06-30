function Set-AzDnsAsCodeConfig
{
    <#
    .SYNOPSIS
        Execute a request against the Azure Management Api to set DNS Entries
    
    .DESCRIPTION
        Execute a request against the Azure Management Api to set DNS Entries
    
    .EXAMPLE
        PS C:\> Set-AzDnsAsCodeConfig -Method PUT -Type A -DNSZone contoso.com -Domain api -TTL 3600 -Target 127.0.0.1

        Set up a new DNS Config for one DNS entry
    #>

    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter (Mandatory=$true)][ValidateSet('GET','PUT','DELETE')][string]$Method,
        [Parameter (Mandatory=$false)][ValidateSet('A','AAAA','CNAME','MX','NS','SOA','SRV','TXT','PTR')][string]$Type,
        [Parameter (Mandatory=$true)][ValidatePattern("^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$")]$DNSZone,
        [Parameter (Mandatory=$false)][ValidatePattern("(^@)|\w+")][string]$Domain,
        [Parameter (Mandatory=$false)][ValidatePattern("\d+")][int]$TTL,
        [string]$Target,
        # MX Paramter
        [Parameter(ParameterSetName='MX', Mandatory=$true)][int]$MXPreference,
        # SRV Paramter
        [Parameter(ParameterSetName='SRV', Mandatory=$true)][ValidatePattern("\d+")][int]$SRVPort,
        [Parameter(ParameterSetName='SRV', Mandatory=$true)][int]$SRVweight,
        [Parameter(ParameterSetName='SRV', Mandatory=$true)][ValidatePattern("\d+")][int]$SRVPriority,
        # SOA Paramter
        [Parameter(ParameterSetName='SOA')][string]$SOAhost,
        [Parameter(ParameterSetName='SOA')][string]$SOAemail,
        [Parameter(ParameterSetName='SOA')][string]$SOAserialnumber,
        [Parameter(ParameterSetName='SOA')][string]$SOArefreshtime,
        [Parameter(ParameterSetName='SOA')][string]$SOAretrytime,
        [Parameter(ParameterSetName='SOA')][string]$SOAexpireTime,
        [Parameter(ParameterSetName='SOA')][string]$SOAminimumTTL,
        $body, # for Multivalue Entries
        # Azure required Parameters
        [Parameter (Mandatory=$true)][String]$SubscriptionID,
        [Parameter (Mandatory=$true)][String]$ResourceGroup
    )

    #region TelemetryData
        $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
        #$data.Add("DNSZone", $DNSZone)
        $data.Add("Method", $Method)
        $data.Add("Type", $Type)
        Add-AzDnsAsCodeTelemetryEvent -Data $data
    #endregion TelemetryData

    #region URL
        $uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/dnszones/$DNSZone/$Type/$($Domain)?api-version=$($script:APIversion)"
    #endregion URL
    #region Body
    if (-not $body) {
        $ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
        $body = Get-Content $ScriptDir\internal\configurations\body.json | ConvertFrom-Json
        if ($Method -eq 'PUT') {
            switch ($type) {
                A {
                    #Var setzen
                        $body.$Method.$type.Value.properties.ARecords[0].ipv4Address = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                AAAA {
                    #Var setzen
                        $body.$Method.$type.Value.properties.AAAARecords[0].ipv6Address = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                CNAME {
                    #Var setzen
                        $body.$Method.$type.Value.properties.CNameRecord[0].cname = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                MX {
                    #Var setzen
                        $body.$Method.$type.Value.properties.MXRecords[0].preference = $MXPreference
                        $body.$Method.$type.Value.properties.MXRecords[0].exchange = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                NS {
                    #Var setzen
                        $body.$Method.$type.Value.properties.NSRecords[0].nsdname = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                        $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                SOA {
                    #Var setzen
                        $body.$Method.$type.Value.properties.SOARecord[0].host = $SOAhost
                        $body.$Method.$type.Value.properties.SOARecord[0].email = $SOAemail
                        $body.$Method.$type.Value.properties.SOARecord[0].serialnumber = $SOAserialnumber
                        $body.$Method.$type.Value.properties.SOARecord[0].refreshtime = $Soarefreshtime
                        $body.$Method.$type.Value.properties.SOARecord[0].retryTime  = $SoaretryTime
                        $body.$Method.$type.Value.properties.SOARecord[0].expireTime = $SOAexpireTime
                        $body.$Method.$type.Value.properties.SOARecord[0].minimumTTL = $SOAminimumTTL
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                SRV {
                    #Var setzen
                        $body.$Method.$type.Value.properties.SRVRecords[0].priority = $SRVPriority
                        $body.$Method.$type.Value.properties.SRVRecords[0].weight = $SRVweight
                        $body.$Method.$type.Value.properties.SRVRecords[0].port = $SRVport
                        $body.$Method.$type.Value.properties.SRVRecords[0].Target = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                TXT {
                    #Var setzen
                        $body.$Method.$type.Value.properties.TXTRecords[0].Value[0] = $Target
                        $body.$Method.$type.Value.properties.TTL = $TTL
                        $body.$Method.$type.Value.properties.metadata.Key1 = $Domain
                    $body = $body.$Method.$Type.Value | ConvertTo-Json -Depth 10
                }
                Default {}
            }
        }
    }
    #endregion Body
    
    #region  API Call
        if (-not $body) {
            $response = AzAPICall -uri $uri -method Get -listenOn Content
        }
        else {
            $response = AzAPICall -uri $uri -method $Method -body $body -listenOn Content
        }
        Write-Output "---------------------------------------------------------------------------------------------------"
        Write-Output "Response:"
    #endregion API Call
    #region Output
    if ($Method -eq 'DELETE' -and [string]::IsNullOrWhiteSpace($response)) {"DELETE complete"}
    else {
        if ($all) { "Anzahl Records: " + $response.value.Count
            $output = $response.Value | Select-Object name, `
            @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
            @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
            @{Name = "Properties"; Expression = { [string]($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
            @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize
        }
        else {
            $output = $response | Select-Object name, `
            @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
            @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
            @{Name = "Properties"; Expression = { [string]($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
            @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize
        }
    }
    #endregion Output
    return $output
}
