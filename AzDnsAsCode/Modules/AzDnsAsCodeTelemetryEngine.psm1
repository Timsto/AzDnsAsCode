function Get-ApplicationInsightsTelemetryClient
{
    [CmdletBinding()]
    param()

    if ($null -eq $Global:AzDnsAsCodeTelemetryEngine)
    {
        #$AI = "$PSScriptRoot\..\Dependencies\Microsoft.ApplicationInsights.dll"
        $AI = "C:\git\AzDnsAsCode\AzDnsAsCode\Dependencies\Microsoft.ApplicationInsights.dll"
        [Reflection.Assembly]::LoadFile($AI) | Out-Null

        $InstrumentationKey = "1b8dc953-96b6-4876-b127-b0d81e911831"
        if ($null -ne $env:AzDnsAsCodeTelemetryInstrumentationKey)
        {
            $InstrumentationKey = $env:AzDnsAsCodeTelemetryInstrumentationKey
        }
        $TelClient = [Microsoft.ApplicationInsights.TelemetryClient]::new()
        $TelClient.InstrumentationKey = $InstrumentationKey

        $Global:AzDnsAsCodeTelemetryEngine = $TelClient
    }
    return $Global:AzDnsAsCodeTelemetryEngine
}

function Add-AzDnsAsCodeTelemetryEvent
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $Type = 'Flow',

        [Parameter()]
        [System.Collections.Generic.Dictionary[[System.String], [System.String]]]
        $Data,

        [Parameter()]
        [System.Collections.Generic.Dictionary[[System.String], [System.Double]]]
        $Metrics
    )

    $TelemetryEnabled = [System.Environment]::GetEnvironmentVariable('AzDnsAsCodeTelemetryEnabled', `
            [System.EnvironmentVariableTarget]::Machine)

    if ($null -eq $TelemetryEnabled -or $TelemetryEnabled -eq $true)
    {
        $TelemetryClient = Get-ApplicationInsightsTelemetryClient

        try
        {
            if ($null -ne $Data.TenantId)
            {
                $principalValue = $Data.TenantId
                $Data.Add("Tenant", $principalValue)
            }

            $Data.Remove("TenandId") | Out-Null

            # Capture PowerShell Version Info
            $Data.Add("PSMainVersion", $PSVersionTable.PSVersion.Major.ToString() + "." + $PSVersionTable.PSVersion.Minor.ToString())
            $Data.Add("PSVersion", $PSVersionTable.PSVersion.ToString())
            $Data.Add("PSEdition", $PSVersionTable.PSEdition.ToString())

            # Capture Console/Host Information
            if ($host.Name -eq "ConsoleHost" -and $null -eq $env:WT_SESSION)
            {
                $Data.Add("PowerShellAgent", "Console")
            }
            elseif ($host.Name -eq "Windows PowerShell ISE Host")
            {
                $Data.Add("PowerShellAgent", "ISE")
            }
            elseif ($host.Name -eq "ConsoleHost" -and $null -ne $env:WT_SESSION)
            {
                $Data.Add("PowerShellAgent", "Windows Terminal")
            }
            elseif ($host.Name -eq "ConsoleHost" -and $null -eq $env:WT_SESSION -and `
                    $null -ne $env:BUILD_BUILDID -and $env:SYSTEM -eq "build")
            {
                $Data.Add("PowerShellAgent", "Azure DevOPS")
                $Data.Add("AzureDevOPSPipelineType", "Build")
                $Data.Add("AzureDevOPSAgent", $env:POWERSHELL_DISTRIBUTION_CHANNEL)
            }
            elseif ($host.Name -eq "ConsoleHost" -and $null -eq $env:WT_SESSION -and `
                    $null -ne $env:BUILD_BUILDID -and $env:SYSTEM -eq "release")
            {
                $Data.Add("PowerShellAgent", "Azure DevOPS")
                $Data.Add("AzureDevOPSPipelineType", "Release")
                $Data.Add("AzureDevOPSAgent", $env:POWERSHELL_DISTRIBUTION_CHANNEL)
            }
            elseif ($host.Name -eq "Default Host" -and `
                    $null -ne $env:APPSETTING_FUNCTIONS_EXTENSION_VERSION)
            {
                $Data.Add("PowerShellAgent", "Azure Function")
                $Data.Add("AzureFunctionWorkerVersion", $env:FUNCTIONS_WORKER_RUNTIME_VERSION)
            }
            elseif ($host.Name -eq "CloudShell")
            {
                $Data.Add("PowerShellAgent", "Cloud Shell")
            }

            [array]$version = (Get-Module 'AzDnsAsCode').Version | Sort-Object -Descending
            $Data.Add("AzDnsAsCodeVersion", $version[0].ToString())

            # Get Dependencies loaded versions
            try
            {
                $currentPath = Join-Path -Path $PSScriptRoot -ChildPath '..\' -Resolve
                $manifest = Import-PowerShellDataFile "$currentPath/AzDnsAsCode.psd1"
                $dependencies = $manifest.RequiredModules

                $dependenciesContent = ""
                foreach ($dependency in $dependencies)
                {
                    $dependenciesContent += Get-Module $dependency.ModuleName | Out-String
                }
                $Data.Add("DependenciesVersion", $dependenciesContent)
            }
            catch
            {
                Write-Verbose -Message $_
            }

            $TelemetryClient.TrackEvent($Type, $Data, $Metrics)
            $TelemetryClient.Flush()
        }
        catch
        {
            Write-Error $_
        }
    }
}

function Set-AzDnsAsCodeTelemetryOption
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.String]
        $InstrumentationKey
    )

    if ($null -ne $Enabled)
    {
        [System.Environment]::SetEnvironmentVariable('AzDnsAsCodeTelemetryEnabled', $Enabled, `
                [System.EnvironmentVariableTarget]::Machine)
    }

    if ($null -ne $InstrumentationKey)
    {
        [System.Environment]::SetEnvironmentVariable('AzDnsAsCodeTelemetryInstrumentationKey', $InstrumentationKey, `
                [System.EnvironmentVariableTarget]::Machine)
    }
}

function Get-AzDnsAsCodeTelemetryOption
{
    [CmdletBinding()]
    param()
    
    try
    {
        return @{
            Enabled            = [System.Environment]::GetEnvironmentVariable('AzDnsAsCodeTelemetryEnabled', `
                    [System.EnvironmentVariableTarget]::Machine)
            InstrumentationKey = [System.Environment]::GetEnvironmentVariable('AzDnsAsCodeTelemetryInstrumentationKey', `
                    [System.EnvironmentVariableTarget]::Machine)
        }
    }
    catch
    {
        throw $_
    }
}
