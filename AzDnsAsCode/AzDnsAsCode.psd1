@{
	# Script module or binary module file associated with this manifest
	RootModule = 'AzDnsAsCode.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.1'
	
	# ID used to uniquely identify this module
	GUID = 'f3ccfc72-148e-4bd3-a8df-b4f1a6c67f05'
	
	# Author of this module
	Author = 'Tim Stock'
	
	# Company or vendor of this module
	CompanyName = 'Microsoft'
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2021 tistock'
	
	# Description of the functionality provided by this module
	Description = 'configure Azure DNS Service as Code'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		#@{ ModuleName='AzApiCall'; ModuleVersion='1.0.0' },
		@{ ModuleName='PSFramework'; ModuleVersion='1.6.197' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\AzDnsAsCode.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\AzDnsAsCode.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\AzDnsAsCode.Format.ps1xml')
	
	# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
	NestedModules     = @(
        'Modules\AzDnsAsCodeTelemetryEngine.psm1'
    )

	# Functions to export from this module
	#FunctionsToExport = @( )
	
	# Cmdlets to export from this module
	CmdletsToExport = @(
		'Get-AzDnsAsCodeZoneConfig'
		'Get-AzDnsAsCodeTelemetryOption'
		'New-AzDnsAsCodeZone'
		'Set-AzDnsAsCodeTelemetryOption'
		'Set-AzDnsAsCodeConfig'
		'Set-AzDnsAsCodeMulticonfig'
		'Show-AzDnsAsCodeConfiguration'	
		'Remove-AzDnsAsCodeZone'
	)
	
	# Variables to export from this module
	#VariablesToExport = ''
	
	# Aliases to export from this module
	#AliasesToExport = ''
	
	# List of all modules packaged with this module
	#ModuleList = @()
	
	# List of all files packaged with this module
	#FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags =  'AzureDNS', 'ConfigasCode'
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/Timsto/AzDnsAsCode/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/Timsto/AzDnsAsCode'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}