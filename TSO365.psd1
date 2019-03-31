@{
    RootModule		= 'TSO365'
    ModuleVersion	= '0.0.1'
    Author		= 'Toby Slight'
    Copyright		= '(c) Toby Slight. All rights reserved.'
    Description		= 'Interact with Microsoft Online Office 365'
    RequiredModules	= @(
	'TSAD'
	'TSUtils'
    )
    FunctionsToExport	= '*'
    CmdletsToExport	= '*'
    VariablesToExport	= '*'
    AliasesToExport	= '*'
    PrivateData		= @{
	PSData		= @{
	}
    }
}
