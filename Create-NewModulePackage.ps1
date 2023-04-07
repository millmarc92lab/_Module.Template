<#
.SYNOPSIS
To Create a new module, cloned from the Module Template

.DESCRIPTION
Clone from the _Module.Template Directory, replace filenames and keywords with new names and keywords
#>

<##>
#Initial Variables for Testing, skip prompts
$ModuleName = 'StealthwatchCloud.Tools'
$ModulePrefix = 'Swct'
$ModuleApplication = 'StealthwatchCloud'
$TargetConsole = 'Stealthwatch Cloud Host'
#$ModuleVersion = Read-Host "Enter the initial version of the Module (0.0.0)"
    $ModuleVersion = '0.0.0'
$ModuleReleaseTag = 'Initial StealthwatchCloud.Tools Module'
$ModuleAuthor = 'Marcus Millender'
$ModuleDescription = 'Powershell module for use in Stealthwatch Cloud Automation'
$ModuleTeamName = 'Security Team'
$ModuleCopyright = 'No Copyright'

<##>

#region: Initialize Variables
# Populate Prompts
<#
$ModuleName = Read-Host "Enter the name of the Module (ex: PaloAlto.Tools)"
$ModulePrefix = Read-Host "Enter a two - four letter prefix to identify the module. (ex: Pat)"
$ModuleApplication = Read-Host "Enter the name of the Application, without spaces. (PaloAlto)"
$TargetConsole = Read-Host "Enter a descriptive name of the target host for which API calls with be made. (ex: Panorama Host)"
#$ModuleVersion = Read-Host "Enter the initial version of the Module (0.0.0)"
    $ModuleVersion = '0.0.0'
$ModuleReleaseTag = Read-Host 'Enter a unique title for the version of this module. (ex: Initial PaloAlto.Tools Module)'
$ModuleAuthor = Read-Host 'Enter the name of the Author: (ex: Firstname Lastname)'
$ModuleDescription = Read-Host 'Enter a brief description of the module. (ex: PowerShell module for use in PaloAlto Automation )'
$ModuleTeamName = Read-Host 'Enter the name of the Team or Company that authored this module'
$ModuleCopyright = Read-Host 'Enter the copyright string. (ex: (c) Palo Alto Team, All rights reserved.)'
#>

"_Module.Template", "$ModuleName" -replace "MTMP", "$ModulePrefix" -replace "_MODULE_APPLICATION", "$ModuleApplication" -replace "_MODULE_TEMPLATE_CONSOLE", "$TargetConsole"

#Template Values
$ModuleName_template = '_Module.Template'
$ModulePrefix_template = 'MTMP'
$ModuleApplication_template = '_MODULE_APPLICATION'
$TargetConsole_template = '_MODULE_TEMPLATE_CONSOLE'
$ModuleVersion_template = '0.0.0'
$ModuleReleaseTag_template = 'Sample Tag: Initial Module Template'
#$ModuleAuthor_template = '[Firstname Lastname]'
$ModuleAuthor_template = '_Firstname_Lastname'
$ModuleDescription_template = 'DESCRIPTION_OF_MODULE'
$ModuleTeamName_template = 'COMPANY_NAME__TEAM'
$ModuleCopyright_template = 'COPYRIGHT_DESCRIPTION'


$Home_Dir = ".\Installer_Template"
$Local_Dir = "."
$ModuleTemplateName = '_Module.Template-0.0.0'
$ModuleTemplateDir = @($Home_Dir,$ModuleTemplateName) -join "\"
<##>
$NewModuleDir = @($Home_Dir,$ModuleName) -join "\"
#Array
$TemplateReplaceStrings = @(
@($ModuleName_template, $ModuleName),
@($ModulePrefix_template, $ModulePrefix),
@($ModuleApplication_template, $ModuleApplication),
@($TargetConsole_template, $TargetConsole),
@($ModuleVersion_template, $ModuleVersion),
@($ModuleReleaseTag_template, $ModuleReleaseTag),
@($ModuleAuthor_template, $ModuleAuthor),
@($ModuleDescription_template, $ModuleDescription),
@($ModuleTeamName_template, $ModuleTeamName),
@($ModuleCopyright_template, $ModuleCopyright)
)

#PSObject
$TemplateReplaceStrings_psobject = @()
foreach ($entry IN $TemplateReplaceStrings) {
    $item = New-Object PsObject
    $item | Add-Member -Type NoteProperty -Name "templateValue" -Value $entry[0]
    $item | Add-Member -Type NoteProperty -Name "Value" -Value $entry[1]
    $TemplateReplaceStrings_psobject += $item
}
<##>
<##
#XML
$TemplateReplaceStrings_xml = [xml] @"
<xml>
<ReplaceStrings><templateValue>$ModuleName_template</templateValue><Value>$ModuleName</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModulePrefix_template</templateValue><Value>$ModulePrefix</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleApplication_template</templateValue><Value>$ModuleApplication</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$TargetConsole_template</templateValue><Value>$TargetConsole</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleVersion_template</templateValue><Value>$ModuleVersion</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleReleaseTag_template</templateValue><Value>$ModuleReleaseTag</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleAuthor_template</templateValue><Value>$ModuleAuthor</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleDescription_template</templateValue><Value>$ModuleDescription</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleTeamName_template</templateValue><Value>$ModuleTeamName</Value></ReplaceStrings>
<ReplaceStrings><templateValue>$ModuleCopyright_template</templateValue><Value>$ModuleCopyright</Value></ReplaceStrings>
</xml>
"@
<##>

#endregion

#region: Set Funtions
function Replace-StringsInFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$TargetFile, #Target File
        [Parameter(Mandatory)] [string]$TargetString, #Target String
        [Parameter(Mandatory)] [string]$NewString #New String
    )

    ((Get-Content -Path $TargetFile) -replace $TargetString, $NewString) | Set-Content -Path $TargetFile
}

function Replace-TemplateValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$InputString, #Input String
        [Parameter(Mandatory)] [Array[]]$ReplaceArray #Replace Array
    )
    
    #foreach ($entry IN $ReplaceArray) { $entry.count; Write-Host $entry[0]; Write-Host $entry[1]; $InputString = $InputString -replace $entry[0], $entry[1] } #Test
    #foreach ($entry IN $ReplaceArray) { $InputString = $InputString -replace $entry[0], $entry[1] } # Array
    foreach ($entry IN $ReplaceArray) { $InputString = $InputString -replace $entry.templateValue, $entry.Value } # PSObject / XML
    return $InputString
}

function Get-ErrorOut($InputError) {
    Write-Host $InputError.InvocationInfo.Line -ForegroundColor Magenta
    Write-Host $InputError.Exception -ForegroundColor Yellow
}
#endregion

#region: Clone and Modify Template Module Package
# Clone and Rename from the Module Template to a new Module Package
Copy-Item -Path $ModuleTemplateDir -Destination $NewModuleDir -Recurse

#Files under Root
$ModulePaths = @()

$DirectoryPath = @{Name="DirectoryPath"; Expression={($_.psparentpath) -replace "Microsoft\.PowerShell.Core\\FileSystem::", "" }}
$NewModulePaths = Get-ChildItem $NewModuleDir -Recurse | Select-Object attributes, fullname, name, $DirectoryPath

# Create PSObjects for Directories, Files, then create a Combined PSObject
foreach ($ModuleDir IN $NewModulePaths) {
    $ModulePathAttributes = ($ModuleDir | Select-Object attributes).attributes
    $ModulePathFullname = ($ModuleDir | Select-Object fullname).fullname
    $ModulePathDirectory = ($ModuleDir | Select-Object DirectoryPath).DirectoryPath
    $ModuleFilename = ($ModuleDir | Select-Object name).name
    $ModulePathUpdated = ($ModuleDir | Select-Object *).fullname -replace "_Module.Template", "$ModuleName" -replace "MTMP", "$ModulePrefix" -replace "_MODULE_APPLICATION", "$ModuleApplication" -replace "_MODULE_TEMPLATE_CONSOLE", "$TargetConsole"
    $ModulePathDirectoryUpdated = ($ModuleDir | Select-Object *).DirectoryPath -replace "_Module.Template", "$ModuleName" -replace "MTMP", "$ModulePrefix" -replace "_MODULE_APPLICATION", "$ModuleApplication" -replace "_MODULE_TEMPLATE_CONSOLE", "$TargetConsole"
    $ModuleFilenameUpdated = ($ModuleDir | Select-Object *).name -replace "_Module.Template", "$ModuleName" -replace "MTMP", "$ModulePrefix" -replace "_MODULE_APPLICATION", "$ModuleApplication" -replace "_MODULE_TEMPLATE_CONSOLE", "$TargetConsole"
    $IsModulePathDirectory = $ModulePathAttributes -match "Directory"
    if ($IsModulePathDirectory) {$ModulePathType = "Directory"} else {$ModulePathType = "File"}

    $ModulePathEntry = New-Object psobject; $ModulePathSelected = $ModuleDir | Select-Object values
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "Value" -Value $ModulePathUpdated
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "TemplateValue" -Value $ModulePathFullname
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "Type" -Value $ModulePathType
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "Filename" -Value $ModuleFilenameUpdated
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "TemplateFilename" -Value $ModuleFilename
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "DirectoryPath" -Value $ModulePathDirectoryUpdated
    $ModulePathEntry | Add-Member -Type NoteProperty -Name "TemplateDirectoryPath" -Value $ModulePathDirectory
    $ModulePaths += $ModulePathEntry
}

#
foreach ($ModulePath IN ($ModulePaths | ? Type -eq "File" | Sort-Object DirectoryPath) ) {
    $ThisDir = $ModulePath.TemplateDirectoryPath
    $ThisFile = $ModulePath.TemplateFilename
    $ThisFile_Updated = $ModulePath.Filename
    #Rename-Item -Path $ModulePath.TemplateValue -NewName $ModulePath.Value
    Rename-Item -Path "$ThisDir\$ThisFile" -NewName "$ThisDir\$ThisFile_Updated"
}

#foreach ($ModulePath IN ($ModulePaths | ? Type -eq "Directory") ) {
foreach ($ModulePath IN ($ModulePaths | ? Type -eq "Directory" | ? TemplateFilename -in $TemplateReplaceStrings_psobject.templateValue ) ) {
    try { Rename-Item -Path $ModulePath.TemplateValue -NewName $ModulePath.Value -ErrorAction Stop } catch { Get-ErrorOut($_) }
}


<#
$ModuleFiles = @(
"Setup.ps1","ModuleInfo.json",
"_Module.Template.psd1","_Module.Template.psm1",
"common\_Module.Template.json","Installer\MTMP.Installer.psm1",
"installer\MTMP.Installer.psm1","installer\config\MTMP.Config.Input.json",
"installer\include\Get-MTMPInstallerInfo.ps1","installer\include\New-MTMPConfig.ps1",
"installer\include\Install-MTMP.ps1"
)
#>

#Replace Module Name
<#
#((Get-Content -Path "$NewModuleDir\Setup.ps1") -replace "_Module\.Template", $ModuleName) | Set-Content -Path "$NewModuleDir\Setup.ps1"
Replace-StringsInFile -TargetFile "$NewModuleDir\Setup.ps1" -TargetString "_Module\.Template" -NewString $ModuleName
Replace-StringsInFile -TargetFile "$NewModuleDir\Setup.ps1" -TargetString "MTMP" -NewString $ModulePrefix
Replace-StringsInFile -TargetFile "$NewModuleDir\Setup.ps1" -TargetString "_MODULE_APPLICATION" -NewString $ModuleApplication
#>
<##
# Template Files
foreach ($Templatefile IN $ModuleTemplateFiles) {
    $ModuleFileName = $Templatefile
    Replace-StringsInFile -TargetFile "$NewModuleDir\Setup.ps1" -TargetString "_MODULE_APPLICATION" -NewString $ModuleApplication
    $ModuleFiles
}
<##>

<##>
# Module Files
foreach ($ModulePath IN ($ModulePaths | ? Type -eq "File" | Sort-Object DirectoryPath)) {
    foreach ($entry IN $TemplateReplaceStrings_psobject) {
        Replace-StringsInFile -TargetFile $ModulePath.Value -TargetString $entry.templateValue -NewString $entry.Value
    }
    #$ModuleFiles
}
<##>

#endregion