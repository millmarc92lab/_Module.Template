using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Security.Principal


<#
.SYNOPSIS
    Install and configure the [_Module.Template] PowerShell module.
.DESCRIPTION
    Setup is intended to be run from a published release of _Module.Template See NOTES
    for details on the expected directory structure.

    There are two main loops of this script:
    1. Prompts for the fields found in MTMP.Config.Input.json
    2. Prompts for credentials found in MTMP.Config.Creds.json
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Setup expects following file structure:

    _Module.Template.zip:
    ├── install\
    │   ├── input\
    │   │   └── (Get-Input commands)
    │   ├── include\
    │   │   └── (Install commands)
    │   ├── _Module.Template.zip
    │   ├── _Module.Template.json
    │   └── MTMP.Installer.psm1
    ├── Setup.ps1
    └── ModuleInfo.json

    <resources>
    <assets>
    <shared>
    <common>
    <packages>
    <content>

    _Module.Template.zip:
    ├── installer\
    │   ├── packages\
    │   │   └── _Module.Template.zip
    │   ├── common\
    │   │   └── _Module.Template.json
    │   │   └── LRLocations.csv
    │   ├── input\
    │   │   └── Get-Input*
    │   │   └── Confirm-*
    │   ├── include\
    │   │   └── (Install commands)
    │   └── MTMP.Installer.psm1
    ├── Setup.ps1
    └── ModuleInfo.json

.LINK
    https://github.com/Example-Tool/Example-Tool
#>

[CmdletBinding()]
Param( )


#region: Import Commands                                                                           
# Import MTMP.Installer
Get-Module MTMP.Installer | Remove-Module -Force
$MTMPInstallerPath = Join-Path -Path $PSScriptRoot -ChildPath "installer"
Import-Module (Join-Path -Path $MTMPInstallerPath -ChildPath "MTMP.Installer.psm1") -Force


# Create / Get Configuration Directory
# NOTE: If a configuration file already exists in AppData and there are significant changes in the latest build,
# the installed version should be overwritten.
$ConfigInfo = New-MTMPConfig

# Import _Module.Template.json
$MTMPConfig = $ConfigInfo.Config

# Import Previous _Module.Template config
if ($ConfigInfo.LastConfig) {
    $PreviousMTMPConfig = $ConfigInfo.LastConfig | ConvertFrom-Json
}


# Import Setup input configuration
$MTMPConfigInput = Get-Content -Path (Join-Path $MTMPInstallerPath "config\MTMP.Config.Input.json") -Raw | ConvertFrom-Json


# Import ModuleInfo
$ModuleInfo = Get-Content -Path "$PSScriptRoot\ModuleInfo.json" | ConvertFrom-Json
#endregion


#region: Banner                                                                       
<##>
$ReleaseTagLength = ($ModuleInfo.ReleaseTag).Length
$s = ""
for ($i = 0; $i -lt $ReleaseTagLength; $i++) {
    $s += "_"
}
Write-Host "                          _         _           _                            _         _"
Write-Host "    _ __ ___    ___    __| | _   _ | |  ___    | |_   ___  _ __ ___   _ __  | |  __ _ | |_   ___"
Write-Host "   | '_ `` _ \  / _ \  / _`` || | | || | / _ \   | __| / _ \| '_ `` _ \ | '_ \ | | / _`` || __| / _ \"
Write-Host "   | | | | | || (_) || (_| || |_| || ||  __/ _ | |_ |  __/| | | | | || |_) || || (_| || |_ |  __/"
Write-Host "   |_| |_| |_| \___/  \__,_| \__,_||_| \___|(_) \__| \___||_| |_| |_|| .__/ |_| \__,_| \__| \___|"
Write-Host "                                                                     |_|"
Write-Host "        $s"
Write-Host "v $($ModuleInfo.Version)      " -NoNewline -ForegroundColor Cyan
Write-Host "$($ModuleInfo.ReleaseTag)" -ForegroundColor Magenta
#endregion



#region: Blurb                                                                                     
Write-Host "`nWelcome to _Module.Template!" -ForegroundColor Green

Write-Host "`nIn the questions that follow, you will be prompted for some basic information about your _MODULE_APPLICATION deployment."
Write-Host "There are also several optional integrations you can enable if you have the necessary licenses or API Keys."
Write-Host "`n* Note *`nIf you already have a configuration file from a previous installation, you can hit [Enter] at any prompt" -ForegroundColor DarkGray
Write-Host "for which you'd like to keep the existing value." -ForegroundColor DarkGray
Write-Host "Configuration Directory: [%LocalAppData%\_Module.Template\_Module.Template.json]" -ForegroundColor DarkGray
#endregion



#region: Setup Walkthrough                                                                         
# FallThruValue is the updated value of the previous field, so a value can be re-used without requiring a prompt.
# This satisfies the use case of not having to prompt the user 4 times to set the _MODULE_APPLICATION API URLs.
$FallThruValue = ""


# $ConfigCategory -> Process each top-level config category (General, _MODULE_APPLICATION, etc.)
foreach($ConfigCategory in $MTMPConfigInput.PSObject.Properties) {
    Write-Host "`n[ $($ConfigCategory.Value.Name) ]`n=========================================" -ForegroundColor Green

    # Display category message to user
    if ($ConfigCategory.Value.Message) {
        Write-Host $ConfigCategory.Value.Message -ForegroundColor DarkGreen
    }
    $ConfigOpt = $true

    #region: Category::Skip Category If Optional                                                               
    # If category is optional, ask user if they want to set it up.
    if ($ConfigCategory.Value.Optional) {
        $ConfigOpt = Confirm-YesNo -Message "Would you like to setup $($ConfigCategory.Value.Name)?"
    }
    # Skip if user chose to skip category
    if (! $ConfigOpt) {
        continue
    }
    #endregion


    #region: Category:: Process Fields Input                                                                
    foreach($ConfigField in $ConfigCategory.Value.Fields.PSObject.Properties) {
        Write-Host "    For guidance enter help or hint as your input value." -ForegroundColor Magenta
        # Input Loop ------------------------------------------------------------------------------
        while (! $ResponseOk) {
            # Exiting Value for this field
            if ($PreviousMTMPConfig) {
                $OldValue = $PreviousMTMPConfig.($ConfigCategory.Name).($ConfigField.Name)
            } else {
                $OldValue = $MTMPConfig.($ConfigCategory.Name).($ConfigField.Name)
            }
            

            # Use previous field's response if this field is marked as FallThru
            if ($ConfigField.Value.FallThru) {
                $Response = $FallThruValue
            # Get / Clean User Input
            } else {
                # $Response = Read-Host -Prompt "  > $($ConfigField.Value.Prompt) [$OldValue]"   #<-- Old value displayed.  Holding off on this.
                $Response = Read-Host -Prompt "  > $($ConfigField.Value.Prompt)"
                $Response = $Response.Trim()
                $Response = Remove-SpecialChars -Value $Response -Allow @("-",".",":")
                Write-Verbose "Response: $Response"
            }
            if (($Response -like "hint") -or ($Response -like 'help')) {
                Write-Host "    Example input: $($ConfigField.Value.Hint)" -ForegroundColor Magenta
                $ResponseOk = $false
                continue
            }

            # Break the loop on this field if no input (keep the same value)
            if ([string]::IsNullOrEmpty($Response)) {
                break
            }

            # > Process Input
            
            Write-Verbose "MTMPConfig.$($ConfigCategory.Name).$($ConfigField.Name)"

            # If we are using Get-StringPattern, run that. 
            if ($ConfigField.Value.InputCmd -match "Get-StringPattern") {
                Write-Verbose "Validation: Get-StringPattern"
                Write-Verbose "Old Value: $OldValue"
                $Result = Get-StringPattern `
                    -Value $Response `
                    -OldValue $OldValue `
                    -Pattern $ConfigField.Value.InputPattern.Pattern `
                    -AllowChars $ConfigField.Value.InputPattern.AllowChars
            } else {
                # Otherwise invoke the command requested with common parameters.
                Write-Verbose "Old Value: $OldValue"
                $cmd = $ConfigField.Value.InputCmd +`
                    " -Value `"" + $Response + "`"" + `
                    " -OldValue `"" + $OldValue + "`""
                    Write-Verbose "Validation: $cmd"

                $Result = Invoke-Expression $cmd -Verbose
            }


            # Input OK - Update configuration object
            if ($Result.Valid) {
                Write-Verbose "Previous Value: $($PreviousMTMPConfig.($ConfigCategory.Name).($ConfigField.Name))"
                Write-Verbose "New Value: $($Result.Value)"
                $ResponseOk = $true
                $MTMPConfig.($ConfigCategory.Name).($ConfigField.Name) = $Result.Value
            # Input BAD - provide hint
            } else {
                Write-Verbose "Validation: `n$Result"
                Write-Host "    hint: [$($ConfigField.Value.Hint)]" -ForegroundColor Magenta
            }
        }
        # End Input Loop --------------------------------------------------------------------------


        # Reset response for next field prompt, set FallThruValue
        $ResponseOk = $false
        $FallThruValue = $Response
    }
    #endregion


    #region: ApiKey Creation                                                                       
    if ($ConfigCategory.Value.HasKey) {

        # Some ApiKeys (oAuth2) will require a Client Id (username)
        if ($ConfigCategory.Value.HasClientId) {

            # Prompt for ClientId if required - no validation other than (length > 2 and < 101)
            $ClientId = Confirm-StringPattern -Message "  > Please enter your Client/App Id" `
                -Pattern "^.{3,100}$" `
                -Hint "Client Id is longer than 2 characters" `
                -AllowChars @("-",".","\")

            # Create credential + username
            $Result = Get-InputCredential `
                -AppId $ConfigCategory.Name `
                -AppName $ConfigCategory.Value.Name `
                -Username $ClientId.Value

        } else {
            # Prompt / create credential without password
            $Result = Get-InputCredential `
                -AppId $ConfigCategory.Name `
                -AppName $ConfigCategory.Value.Name
        }
    }
    #endregion

    #region: Credential Creation                                                                       
    if ($ConfigCategory.Value.HasCredential) {

        # Prompt for Username - no validation other than (length > 2 and < 101)
        $Username = Confirm-StringPattern -Message "  > Please enter your Username" `
            -Pattern "^.*$" `
            -Hint 'Username is any letters, numbers and any of the following: "-",".","\", "@", "_"' `
            -AllowChars @("-",".","\", "@", "_")

        # Make sure Username is not empty, as it otherwise cause error
        if ([string]::IsNullOrEmpty($Username.Value)) {
            $Username.Value = $ConfigCategory.Name
        }

        # Create credential + username
        $Result = Get-InputCredential `
            -AppId $ConfigCategory.Name `
            -AppName $ConfigCategory.Value.Name `
            -Username $Username.Value `
            -UserCredential

    }
    #endregion



    # Write Config
    Write-Verbose "Writing Config to $($ConfigInfo.ConfigFilePath)"
    $MTMPConfig | ConvertTo-Json | Set-Content -Path $ConfigInfo.ConfigFilePath -Force
}
#endregion



#region: Install Options                                                                           
# Find Install Archive
$ArchiveFileName = $ModuleInfo.Name + ".zip"

if ($PSEdition -like 'Core'){
    if ($IsWindows) {
        $ArchivePath = "$PSScriptRoot\installer\packages\$ArchiveFileName"
    } elseif ($IsLinux -or $IsMacOS) {
        $ArchivePath = "$PSScriptRoot/installer/packages/$ArchiveFileName"
    }
} else {
    $ArchivePath = "$PSScriptRoot\installer\packages\$ArchiveFileName"
}

if (! (Test-Path $ArchivePath)) {
    $Err = "Could not locate install archive $ArchivePath. Replace the archive or re-download this release. "
    $Err += "Alternatively, you can install manually using: Install-MTMP -Path <path to archive>"
    throw [FileNotFoundException] $Err
}


# Start Install Options
Write-Host "`n[ Install Options ]`n=========================================" -ForegroundColor Cyan
$ConfirmInstall = Confirm-YesNo -Message "Would you like to install the module now?"
if (! $ConfirmInstall) {
    Write-Host "Not installing. Finished."
    return
}


# Install Scope
$Scopes = @("User","System")
Write-Host "  > You can install this module for the current user (profile) or system-wide (program files)."
Write-Host "  -- Notice --`n    API Credentials are only accessible to the user currently installing _Module.Template"
if ($PSEdition -like 'Core'){
    if ($IsWindows) {
        Write-Host "    Current User: $($env:UserName)" -ForegroundColor Magenta
    } elseif ($IsLinux -or $IsMacOS) {
        Write-Host "    Current User: $(whoami)" -ForegroundColor Magenta
    }
} else {
    Write-Host "    Current User: $($env:UserName)" -ForegroundColor Magenta
}
$InstallScope = Confirm-Selection -Message "  > Install for user or system?" -Values $Scopes


try {
  Install-MTMP -Path $ArchivePath -Scope $InstallScope.Value
  $Installed = $true
} catch {
    $Installed = $false
    $Err = $PSItem.Exception.Message
    Write-Host "`n  ** Error occurred during installation **" -ForegroundColor Yellow
    Write-Host "  Message: $Err" -ForegroundColor Red
}

if ($Installed) {
    Write-Host "`n<_Module.Template module successfully installed for scope $($InstallScope.Value).>" -ForegroundColor Green
    Write-Host "`n-----------------------`nTo get started: `n> Import-Module _Module.Template"
} else {
    Write-Host "  <Setup failed to install _Module.Template>" -ForegroundColor Yellow
}
#endregion