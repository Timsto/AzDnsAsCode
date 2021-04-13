# ht for BearerToken
$script:htBearerAccessToken = [System.Collections.Hashtable]::Synchronized((New-Object System.Collections.Hashtable))
$script:ApiVersion = '2018-05-01'