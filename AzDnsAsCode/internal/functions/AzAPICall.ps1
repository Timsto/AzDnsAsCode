function AzAPICall
{
    <#
    .SYNOPSIS
        Execute the API Call
    
    .DESCRIPTION
        Execute the API Call
    

    .PARAMETER uri
        URI for the request


    .PARAMETER method
        Method for the request
            @("Get","Put","POST","DELETE")

    .PARAMETER currenttask 
        Show the current Task as output

    .EXAMPLE
        PS C:\> AziApiCall -uri 'https://graph.microsoft.com/beta/users' -method GET
        Returns information about all Users
    #>
	[CmdletBinding()]
	param (
		$uri,

		$method,

		$currentTask,

		$body,

		$listenOn
	)
    #$debugAzAPICall = $true
    $tryCounter = 0
    $tryCounterUnexpectedError = 0
    $retryAuthorizationFailed = 5
    $retryAuthorizationFailedCounter = 0
    $apiCallResultsCollection = [System.Collections.ArrayList]@()
    $initialUri = $uri
    $restartDueToDuplicateNextlinkCounter = 0

    do {
        if ($uri -like "*management.azure.com*") {
            $targetEndpoint = "ManagementAPI"
            $bearerToUse = $script:htBearerAccessToken.AccessTokenManagement
        }
        else {
            $targetEndpoint = "GraphAPI"
            $bearerToUse = $script:htBearerAccessToken.AccessTokenGraph
        }
<# 
        #API Call Tracking
        $tstmp = (Get-Date -format "yyyyMMddHHmmssms")
        $null = $script:arrayAPICallTracking.Add([PSCustomObject]@{ 
                CurrentTask    = $currentTask
                TargetEndpoint = $targetEndpoint
                Uri            = $uri
                Method         = $method
                TryCounter = $tryCounter
                TryCounterUnexpectedError = $tryCounterUnexpectedError
                RetryAuthorizationFailedCounter = $retryAuthorizationFailedCounter
                RestartDueToDuplicateNextlinkCounter = $restartDueToDuplicateNextlinkCounter
                TimeStamp = $tstmp
            })
        
        if ($caller -eq "CustomDataCollection"){
            $null = $script:arrayAPICallTrackingCustomDataCollection.Add([PSCustomObject]@{ 
                    CurrentTask    = $currentTask
                    TargetEndpoint = $targetEndpoint
                    Uri            = $uri
                    Method         = $method
                    TryCounter = $tryCounter
                    TryCounterUnexpectedError = $tryCounterUnexpectedError
                    RetryAuthorizationFailedCounter = $retryAuthorizationFailedCounter
                    RestartDueToDuplicateNextlinkCounter = $restartDueToDuplicateNextlinkCounter
                    TimeStamp = $tstmp
                })
        }
#>
        $unexpectedError = $false
        $tryCounter++
        if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "  DEBUGTASK: attempt#$($tryCounter) processing: $($currenttask)" }
        try {
            if ($body) {
                #write-host "has BODY"
                $azAPIRequest = Invoke-WebRequest -Uri $uri -Method $method -body $body -Headers @{"Content-Type" = "application/json"; "Authorization" = "Bearer $bearerToUse" } -ContentType "application/json" -UseBasicParsing
            }
            else {
                $azAPIRequest = Invoke-WebRequest -Uri $uri -Method $method -Headers @{"Content-Type" = "application/json"; "Authorization" = "Bearer $bearerToUse" } -UseBasicParsing
            }
        }
        catch {
            try {
                $catchResultPlain = $_.ErrorDetails.Message
                $catchResult = ($catchResultPlain | ConvertFrom-Json -ErrorAction SilentlyContinue) 
            }
            catch {
                $catchResult = $catchResultPlain
                $tryCounterUnexpectedError++
                $unexpectedError = $true
            }
        }
        
        if ($unexpectedError -eq $false) {
            if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: unexpectedError: false" }
            if ($azAPIRequest.StatusCode -ne 200 -and $azAPIRequest.StatusCode -ne 201) {
                if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: apiStatusCode: $($azAPIRequest.StatusCode)" }
                if ($catchResult.error.code -like "*GatewayTimeout*" -or $catchResult.error.code -like "*BadGatewayConnection*" -or 
                    $catchResult.error.code -like "*InvalidGatewayHost*" -or $catchResult.error.code -like "*ServerTimeout*" -or 
                    $catchResult.error.code -like "*ServiceUnavailable*" -or $catchResult.code -like "*ServiceUnavailable*" -or 
                    $catchResult.error.code -like "*MultipleErrorsOccurred*" -or $catchResult.error.code -like "*InternalServerError*" -or 
                    $catchResult.error.code -like "*RequestTimeout*" -or $catchResult.error.code -like "*AuthorizationFailed*" -or 
                    $catchResult.error.code -like "*ExpiredAuthenticationToken*" -or $catchResult.error.code -like "*ResponseTooLarge*" -or 
                    $catchResult.error.code -like "*InvalidAuthenticationToken*" -or ($getConsumption -and $catchResult.error.code -eq 404) -or
                    $catchResult.error.code -like "*AuthenticationFailedMissingToken*" -or 
                    ($getSp -and $catchResult.error.code -like "*Request_ResourceNotFound*") -or 
                    ($getSp -and $catchResult.error.code -like "*Authorization_RequestDenied*") -or
                    ($getApp -and $catchResult.error.code -like "*Request_ResourceNotFound*") -or 
                    ($getApp -and $catchResult.error.code -like "*Authorization_RequestDenied*") -or 
                    ($getGuests -and $catchResult.error.code -like "*Authorization_RequestDenied*") -or 
                    $catchResult.error.message -like "*The offer MS-AZR-0110P is not supported*" -or
                    $catchResult.error.code -like "*UnknownError*") {
                    if ($catchResult.error.code -like "*ResponseTooLarge*") {
                        Write-Host "###### LIMIT #################################"
                        Write-Host "Hitting LIMIT getting Policy Compliance States!"
                        Write-Host "ErrorCode: $($catchResult.error.code)"
                        Write-Host "ErrorMessage: $($catchResult.error.message)"
                        Write-Host "There is nothing we can do about this right now. Please run AzGovViz with the following parameter: '-NoPolicyComplianceStates'." -ForegroundColor Yellow
                        Write-Host "Impact using parameter '-NoPolicyComplianceStates': only policy compliance states will not be available in the various AzGovViz outputs - all other output remains." -ForegroundColor Yellow
                        if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                            Write-Error "Error"
                        }
                        else {
                            break # Break Script
                        }
                    }
                    if ($catchResult.error.message -like "*The offer MS-AZR-0110P is not supported*") {
                        Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - seems weÂ´re hitting a malicious endpoint .. try again in $tryCounter second(s)"
                        Start-Sleep -Seconds $tryCounter
                    }
                    if ($catchResult.error.code -like "*GatewayTimeout*" -or $catchResult.error.code -like "*BadGatewayConnection*" -or $catchResult.error.code -like "*InvalidGatewayHost*" -or $catchResult.error.code -like "*ServerTimeout*" -or $catchResult.error.code -like "*ServiceUnavailable*" -or $catchResult.code -like "*ServiceUnavailable*" -or $catchResult.error.code -like "*MultipleErrorsOccurred*" -or $catchResult.error.code -like "*InternalServerError*" -or $catchResult.error.code -like "*RequestTimeout*" -or $catchResult.error.code -like "*UnknownError*") {
                        Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - try again"
                        Start-Sleep -Seconds $tryCounter
                    }
                    if ($catchResult.error.code -like "*AuthorizationFailed*") {
                        if ($retryAuthorizationFailedCounter -gt $retryAuthorizationFailed) {
                            Write-Host " $currentTask - try #$tryCounter; returned: '$($catchResult.error.code)' | '$($catchResult.error.message)' - $retryAuthorizationFailed retries failed - investigate that error!/exit"
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Error - check the last console output for details"
                            }
                        }
                        else {
                            if ($retryAuthorizationFailedCounter -gt 2) {
                                Start-Sleep -Seconds 5
                            }
                            if ($retryAuthorizationFailedCounter -gt 3) {
                                Start-Sleep -Seconds 10
                            }
                            Write-Host " $currentTask - try #$tryCounter; returned: '$($catchResult.error.code)' | '$($catchResult.error.message)' - not reasonable, retry #$retryAuthorizationFailedCounter of $retryAuthorizationFailed"
                            $retryAuthorizationFailedCounter ++
                        }
                    }
                    if ($catchResult.error.code -like "*ExpiredAuthenticationToken*" -or $catchResult.error.code -like "*InvalidAuthenticationToken*" -or $catchResult.error.code -like "*AuthenticationFailedMissingToken*") {
                        Write-Host " $currentTask - try #$tryCounter; returned: '$($catchResult.error.code)' | '$($catchResult.error.message)' - requesting new bearer token ($targetEndpoint)"
                        createBearerToken -targetEndPoint $targetEndpoint
                    }
                    if ($getConsumption -and $catchResult.error.code -eq 404) {
                        Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - (plain : $catchResult) seems Subscriptions was created only recently - skipping"
                        return $apiCallResultsCollection
                    }
                    if (($getApp -or $getSp) -and $catchResult.error.code -like "*Request_ResourceNotFound*") {
                        Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - (plain : $catchResult) uncertain ServicePrincipal status - skipping for now :)"
                        return "Request_ResourceNotFound"
                    }
                    if ((($getApp -or $getSp) -and $catchResult.error.code -like "*Authorization_RequestDenied*") -or ($getGuests -and $catchResult.error.code -like "*Authorization_RequestDenied*")) {
                        if ($userType -eq "Guest") {
                            Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - (plain : $catchResult)"
                            Write-Host " AzGovViz says: You are a 'Guest' User in the tenant therefore not enough permissions. You have the following options: [1. request membership to AAD Role 'Directory readers'.] [2. Use parameters '-NoAADGuestUsers' and '-NoAADServicePrincipalResolve'.] [3. Grant explicit Microsoft Graph API permission. Permissions reference Users: https://docs.microsoft.com/en-us/graph/api/user-list | Applications: https://docs.microsoft.com/en-us/graph/api/application-list]" -ForegroundColor Yellow
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Authorization_RequestDenied"
                            }
                        }
                        else {
                            Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - (plain : $catchResult) investigate that error!/exit"
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Authorization_RequestDenied"
                            }
                        }
                    }                    
                }
                else {
                    Write-Host " $currentTask - try #$tryCounter; returned: <.code: '$($catchResult.code)'> <.error.code: '$($catchResult.error.code)'> | <.message: '$($catchResult.message)'> <.error.message: '$($catchResult.error.message)'> - (plain : $catchResult) investigate that error!/exit"
                    if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                        Write-Error "Error"
                    }
                    else {
                        Throw "Error - check the last console output for details"
                    }
                }
            }
            else {
                if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: apiStatusCode: $($azAPIRequest.StatusCode)" }
                $azAPIRequestConvertedFromJson = ($azAPIRequest.Content | ConvertFrom-Json)
                if ($listenOn -eq "Content") {       
                    if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: listenOn=content ($((($azAPIRequestConvertedFromJson) | Measure-Object).count))" }      
                    $null = $apiCallResultsCollection.Add($azAPIRequestConvertedFromJson)
                }
                elseif ($listenOn -eq "ContentProperties") {
                    if (($azAPIRequestConvertedFromJson.properties.rows | Measure-Object).Count -gt 0) {
                        foreach ($consumptionline in $azAPIRequestConvertedFromJson.properties.rows) {
                            $null = $apiCallResultsCollection.Add([PSCustomObject]@{ 
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[0])" = $consumptionline[0]
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[1])" = $consumptionline[1]
                                    SubscriptionMgPath                                             = $htSubscriptionsMgPath.($consumptionline[1]).ParentNameChain
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[2])" = $consumptionline[2]
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[3])" = $consumptionline[3]
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[4])" = $consumptionline[4]
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[5])" = $consumptionline[5]
                                    "$($azAPIRequestConvertedFromJson.properties.columns.name[6])" = $consumptionline[6]
                                })
                        }
                    }
                }
                else {       
                    if (($azAPIRequestConvertedFromJson).properties) {
                        if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: listenOn=default(value) value exists ($((($azAPIRequestConvertedFromJson).value | Measure-Object).count))" }
                        $null = $apiCallResultsCollection.AddRange($azAPIRequestConvertedFromJson.properties)
                    }
                    else {
                        if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: listenOn=default(value) value not exists; return empty array" }
                    }
                }

                $isMore = $false
                if ($azAPIRequestConvertedFromJson.nextLink) {
                    $isMore = $true
                    if ($uri -eq $azAPIRequestConvertedFromJson.nextLink) {
                        if ($restartDueToDuplicateNextlinkCounter -gt 3) {
                            Write-Host " $currentTask restartDueToDuplicateNextlinkCounter: #$($restartDueToDuplicateNextlinkCounter) - Please report this error/exit"
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Error - check the last console output for details"
                            }
                        }
                        else {
                            $restartDueToDuplicateNextlinkCounter++
                            Write-Host "nextLinkLog: uri is equal to nextLinkUri"
                            Write-Host "nextLinkLog: uri: $uri"
                            Write-Host "nextLinkLog: nextLinkUri: $($azAPIRequestConvertedFromJson.nextLink)"
                            Write-Host "nextLinkLog: re-starting (#$($restartDueToDuplicateNextlinkCounter)) '$currentTask'"
                            $apiCallResultsCollection = [System.Collections.ArrayList]@()
                            $uri = $initialUri
                            Start-Sleep -Seconds 1
                            createBearerToken -targetEndPoint $targetEndpoint
                            Start-Sleep -Seconds 1
                        }
                    }
                    else {
                        $uri = $azAPIRequestConvertedFromJson.nextLink
                    }
                    if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: nextLink: $Uri" }
                }
                elseIf ($azAPIRequestConvertedFromJson."@oData.nextLink") {
                    $isMore = $true
                    if ($uri -eq $azAPIRequestConvertedFromJson."@odata.nextLink") {
                        if ($restartDueToDuplicateNextlinkCounter -gt 3) {
                            Write-Host " $currentTask restartDueToDuplicate@odataNextlinkCounter: #$($restartDueToDuplicateNextlinkCounter) - Please report this error/exit"
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Error - check the last console output for details"
                            }
                        }
                        else {
                            $restartDueToDuplicateNextlinkCounter++
                            Write-Host "nextLinkLog: uri is equal to @odata.nextLinkUri"
                            Write-Host "nextLinkLog: uri: $uri"
                            Write-Host "nextLinkLog: @odata.nextLinkUri: $($azAPIRequestConvertedFromJson."@odata.nextLink")"
                            Write-Host "nextLinkLog: re-starting (#$($restartDueToDuplicateNextlinkCounter)) '$currentTask'"
                            $apiCallResultsCollection = [System.Collections.ArrayList]@()
                            $uri = $initialUri
                            Start-Sleep -Seconds 1
                            createBearerToken -targetEndPoint $targetEndpoint
                            Start-Sleep -Seconds 1
                        }
                    }
                    else {
                        $uri = $azAPIRequestConvertedFromJson."@odata.nextLink"
                    }
                    if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: @oData.nextLink: $Uri" }
                }
                elseif ($azAPIRequestConvertedFromJson.properties.nextLink) {              
                    $isMore = $true
                    if ($uri -eq $azAPIRequestConvertedFromJson.properties.nextLink) {
                        if ($restartDueToDuplicateNextlinkCounter -gt 3) {
                            Write-Host " $currentTask restartDueToDuplicateNextlinkCounter: #$($restartDueToDuplicateNextlinkCounter) - Please report this error/exit"
                            if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                                Write-Error "Error"
                            }
                            else {
                                Throw "Error - check the last console output for details"
                            }
                        }
                        else {
                            $restartDueToDuplicateNextlinkCounter++
                            Write-Host "nextLinkLog: uri is equal to nextLinkUri"
                            Write-Host "nextLinkLog: uri: $uri"
                            Write-Host "nextLinkLog: nextLinkUri: $($azAPIRequestConvertedFromJson.properties.nextLink)"
                            Write-Host "nextLinkLog: re-starting (#$($restartDueToDuplicateNextlinkCounter)) '$currentTask'"
                            $apiCallResultsCollection = [System.Collections.ArrayList]@()
                            $uri = $initialUri
                            Start-Sleep -Seconds 1
                            createBearerToken -targetEndPoint $targetEndpoint
                            Start-Sleep -Seconds 1
                        }
                    }
                    else {
                        $uri = $azAPIRequestConvertedFromJson.properties.nextLink
                    }
                    if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: nextLink: $Uri" }
                }
                else {
                    if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: NextLink: none" }
                }
            }
        }
        else {
            if ($htParameters.DebugAzAPICall -eq $true) { Write-Host "   DEBUG: unexpectedError: notFalse" }
            if ($tryCounterUnexpectedError -lt 10) {
                $sleepSec = @(1,2,3,5,10,20,30,40,50,60)[$tryCounterUnexpectedError]
                Write-Host " $currentTask #$tryCounterUnexpectedError 'Unexpected Error' occurred (trying 10 times); sleep $sleepSec seconds"
                Write-Host $catchResult
                Start-Sleep -Seconds $sleepSec
            }
            else {
                Write-Host " $currentTask #$tryCounterUnexpectedError 'Unexpected Error' occurred (tried 5 times)/exit"
                if ($htParameters.AzureDevOpsWikiAsCode -eq $true) {
                    Write-Error "Error"
                }
                else {
                    Throw "Error - check the last console output for details"
                }
            }
        }
    }
    until(($azAPIRequest.StatusCode -eq 200 -or $azAPIRequest.StatusCode -eq 201) -and -not $isMore)
    return $apiCallResultsCollection
}
