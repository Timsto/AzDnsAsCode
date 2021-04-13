# AzDNS as Code 

This Module will support you with handle your DNS zones within Azure. Write your Zones and Entries to the zone-config.json und commit it to your codebase.  

For more information For information on how to get started, additional dokumentation or examples, check out the [Wiki](https://github.com/timsto/AzDnsAsCode/wiki)


# Installation
```powershell 
PS C:\> Install-Module AzDnsAsCode 
```
# Example 
### Single 
```powershell 
PS C:\> Set-AzDnsAsCodeConfig -Method PUT -Type A -DNSZone contoso.com -Domain api -TTL 3600 -Target 127.0.0.1
```

### Multi
```powershell 
PS C:\> Set-AzDnsAsCodeMultiConfig -ZoneConfigPath .\zone-config.json
```



# Authentication
This module will use your Powershell Azure Context. Just connect with Connect-AzAccount and start working on DNS Infrastructure

Allowed Azure AD object types: 
  - user
  - Service Principal
  - Managed Identity (need to be checked!)

# Permissions
Need the following role from Azure Role-based Access Control: 
- DNS Zone Contributor
# Common Issues
- private Azure DNS currently not working
- Check your permissions on the zone. 