# AzDNS as Code 

This Module will support you with handle your DNS zones within Azure. Write your Zones and Entries to the zone-config.json und commit it to your codebase.  

For more information For information on how to get started, additional dokumentation or examples, check out the [Wiki](https://github.com/timsto/AzDnsAsCode/wiki)

## Installation
```powershell 
PS C:\> Install-Module AzDnsAsCode 
```
## Example 
### Single 
```powershell 
PS C:\> Set-AzDnsAsCodeConfig -Method PUT -Type A -DNSZone contoso.com -Domain api -TTL 3600 -Target 127.0.0.1
```

### Multi
```powershell 
PS C:\> Set-AzDnsAsCodeMultiConfig -ZoneConfigPath .\zone-config.json
```

### Zoneconfig 
```json
{
    "fabrikam.net":{ 
        "A": {
            "www":{
                "properties": {
                "metadata": {
                    "Owner": "CTO",
                    "Department": "Design"
                },
                "TTL": 3600,
                "ARecords": [
                    {
                    "ipv4Address": "127.13.2.1"
                    }
                ]
                }
            }, 
            "api":{
                "properties": {
                    "TTL": 3601,
                    "ARecords": [
                        {
                        "ipv4Address": "127.3.3.1"
                        }
                    ]
                }
            }
        }
    }
}
```
## Authentication
This module will use your Powershell Azure Context. Just connect with Connect-AzAccount and start working on DNS Infrastructure

Allowed Azure AD object types: 
  - user
  - Service Principal
  - Managed Identity (need to be checked!)

## Permissions
Need the following role from Azure Role-based Access Control: 
- DNS Zone Contributor
## Common Issues
- private Azure DNS currently not working
- Check your permissions on the zone. 

# Telemetry Data
 AzDnsAsCode captures Telemetry data about following Data: 
- Method
- Type 
- Version
- usageLocation

Users can opt-out to prevent telemetry from being sent back to the 'AzDnsAsCode' team by running the following command:

```powershell 
PS C:\> Set-AzDnsAsCodeTelemetryOption -Enabled $False
```