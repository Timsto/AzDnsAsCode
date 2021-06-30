function Show-AzDnsAsCodeConfiguration
{
    <#
    .SYNOPSIS
        Show current config from .json file
    
    .DESCRIPTION
        Show current config from .json file
    

    .PARAMETER ZoneConfigPath
        Location of the internal templat
    .EXAMPLE
        PS C:\> Show-AzDnsAsCodeTemplate
        
        Show current config
    #>

    [CmdletBinding()]
    param (
        [String]$ZoneConfigPath = "$PSScriptRoot/internal/configuratins/body.json"
    )
    
    begin {
        $json = Get-Content -Path $ZoneConfigPath | convertfrom-json
    }
    
    process {
        foreach ($DNSZone in $json.psobject.Properties) {
            $DNSZone = $DNSZone.Name
            Write-Output "Domain: $DNSZone"
               
            foreach ($type in $json.($DNSZone).psobject.Properties) {
                $Type = $type.Name;
                Write-Output "-Type = $Type"
        
                foreach ($Domain in $json.$DNSZone.($type).psobject.Properties) {
                    $Domain = $Domain.Name
                    Write-Output "--Entries"

                    $json.$DNSZone.($type).$Domain | Select-Object `
                    @{Name = "Type"; Expression = {($_.properties | Get-Member | Where-Object {$_.Name -like "*Recor*"}).Name -replace "Records","" -replace "Record",""}}, `
                    @{Name = "TTL"; Expression = {"$($_.properties.TTL)"}}, `
                    @{Name = "Properties"; Expression = {($_.properties | Select-Object -ExpandProperty "*Recor*")}}, `
                    @{Name = "MetaData"; Expression = {"$($_.properties.metadata)"}} | Format-Table -AutoSize
                }
            }
            Write-Output "---------------------------------------------------------------"
        }
    }
}
