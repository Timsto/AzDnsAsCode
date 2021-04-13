function Show-AzDnsAsCodeConfiguration
{
    <#
    .SYNOPSIS
        Execute a request to create a new Azure DNS Zone
    
    .DESCRIPTION
        Execute a request to create a new Azure DNS Zone
    

    .PARAMETER path
        Location of the internal templat
    .EXAMPLE
        PS C:\> Show-AzDnsAsCodeTemplate
    
    #>

    [CmdletBinding()]
    param (
        [String]$ZoneConfigPath = "$PSScriptRoot/internal/configuratins/body.json"
    )
    
    begin {
        $ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
        $json = Get-Content -Path $ZoneConfigPath | convertfrom-json
    }
    
    process {
        foreach ($DNSZone in $json.psobject.Properties) {
            $DNSZone = $DNSZone.Name
            Write-Output "Domain: $DNSZone"
            
            #Test is Domain exist
    
            foreach ($type in $json.($DNSZone).psobject.Properties) {
                $Type = $type.Name;
                Write-Output "-Type = $Type"
        
                foreach ($Domain in $json.$DNSZone.($type).psobject.Properties) {
                    $Domain = $Domain.Name
                    Write-Output "--Entries"

                    $json.$DNSZone.($type).$Domain | Select-Object `
                    @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
                    @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
                    @{Name = "Properties"; Expression = { ($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
                    @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize
                }
            }
            Write-Output "---------------------------------------------------------------"
        }
    }
}
