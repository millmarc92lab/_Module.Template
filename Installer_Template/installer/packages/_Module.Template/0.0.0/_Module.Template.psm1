
#region: Module Info                                                                     
# (Optional) Modify the $ModuleConfig Varible name to a name that identifies with the tool. Example, if the module is for the Palo Alto Networks firewall API, name it $PanConfig.  This will be referenced in various other scripts.
 # Module Name: To make it easier to change the name of the module.
# NOTE: These two variables should be set exactly the same as they appear in setup\New-MTMPConfig!
#       The name of the file may be $ModuleName.config.json, but the object is still called
$ModuleName = "_Module.Template"
$PreferencesFileName = $ModuleName + ".json"

# [Namespaces]: Directories to include in this module
$Namespaces = @(
    "Public",
    "Private"
)
#endregion



#region: Load Preferences                                                                
$ConfigDirPath = Join-Path `
    -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
    -ChildPath $ModuleName

$ConfigFileInfo = [System.IO.FileInfo]::new((Join-Path -Path $ConfigDirPath -ChildPath $PreferencesFileName))

# Try to load the Config File from Local AppData or fail
if ($ConfigFileInfo.Exists) {
    $MTMPConfig = Get-Content -Path $ConfigFileInfo.FullName -Raw | ConvertFrom-Json
} else {
    throw [Exception] "Failed to load configuration from [$ConfigDirPath]. Run Setup.ps1 to create required configuration items."
}
#endregion



#region: Module Reference Object Variables                                               
# LogRhythm Case Vars
$LrCaseStatus = [PSCustomObject]@{
    Created     = 1
    Completed   = 2
    Incident    = 3
    Mitigated   = 4
    Resolved    = 5
}


# HTTP Vars
$HttpMethod = [PSCustomObject]@{
    Get     = "Get"
    Head    = "Head"
    Post    = "Post"
    Put     = "Put"
    Delete  = "Delete"
    Trace   = "Trace"
    Options = "Options"
    Merge   = "Merge"
    Patch   = "Patch"
}


$HttpContentType = [PSCustomObject]@{
    Json        = "application/json"
    Text        = "text/plain"
    Html        = "text/html"
    Xml         = "application/xml"
    JavaScript  = "application/javascript"
    FormUrl     = "application/x-www-form-urlencoded"
    FormData    = "multipart/form-data"
}
#endregion



#region: Import Functions                                                                
# Build Import Hash Table
$Includes = @{}
foreach ($namespace in $Namespaces) {
    $Includes.Add($namespace, @(Get-ChildItem -Recurse -Include *.ps1 -Path $PSScriptRoot\$namespace -ErrorAction SilentlyContinue))
}
# Run Import
foreach ($include in $Includes.GetEnumerator()) {
    foreach ($file in $include.Value) {
        try {
            . $file.FullName
        }
        catch {
            Write-Error "  - Failed to import function $($file.BaseName): $_"
        }
    }
}
#endregion



#region: Import API Keys and Credential (Username + Password)
foreach($ConfigCategory in $MTMPConfig.PSObject.Properties) {
    # Import API Keys
    if($ConfigCategory.Value.PSObject.Properties.Name -eq "ApiKey") {
        $KeyFileName = $ConfigCategory.Name + ".ApiKey.xml"
        $KeyFile = [System.IO.FileInfo]::new((Join-Path -Path $ConfigDirPath -ChildPath $KeyFileName))
        if ($KeyFile.Exists) {
            $MTMPConfig.($ConfigCategory.Name).ApiKey = Import-Clixml -Path $KeyFile.FullName
            Write-Verbose "[$($ConfigCategory.Name)]: Loaded API Key"
        } else {
            Write-Verbose "[$($ConfigCategory.Name)]: API key not found"
        }
    }

    # Credential
    if($ConfigCategory.Value.PSObject.Properties.Name -eq "Credential") {
        $KeyFileName = $ConfigCategory.Name + ".Credential.xml"
        $KeyFile = [System.IO.FileInfo]::new((Join-Path -Path $ConfigDirPath -ChildPath $KeyFileName))
        if ($KeyFile.Exists) {
            $MTMPConfig.($ConfigCategory.Name).Credential = Import-Clixml -Path $KeyFile.FullName
            Write-Verbose "[$($ConfigCategory.Name)]: Loaded Credential"
        } else {
            Write-Verbose "[$($ConfigCategory.Name)]: Credential not found"
        }
    }
}
#endregion

#region: Bring Proxy settings to global:PSDefaultParameterValues 
if ($MTMPConfig.Proxy.Required -And ($MTMPConfig.Proxy.Host.Length -gt 0)) {
    # Proxy URL
    $ProxyUrl = "http://{0}" -f $MTMPConfig.Proxy.Host
    if ($MTMPConfig.Proxy.Port.Length -gt 0) {
        $ProxyUrl += ":{0}" -f $MTMPConfig.Proxy.Port
    }
    if (-Not $PSDefaultParameterValues.ContainsKey('Invoke-RestMethod:Proxy')) {
        $PSDefaultParameterValues.Add('Invoke-RestMethod:Proxy', $ProxyUrl)
    }
    if (-Not $PSDefaultParameterValues.ContainsKey('Invoke-WebRequest:Proxy')) {
        $PSDefaultParameterValues.Add('Invoke-WebRequest:Proxy', $ProxyUrl)
    }

    # Credential
    if ($MTMPConfig.Proxy.RequiresCredential -And ($MTMPConfig.Proxy.Credential.GetType().Name -eq 'PSCredential')) {
        if (-Not $PSDefaultParameterValues.ContainsKey('Invoke-RestMethod:ProxyCredential')) {
            $PSDefaultParameterValues.Add('Invoke-RestMethod:ProxyCredential',$MTMPConfig.Proxy.Credential)
        }
        if (-Not $PSDefaultParameterValues.ContainsKey('Invoke-WebRequest:ProxyCredential')) {
            $PSDefaultParameterValues.Add('Invoke-WebRequest:ProxyCredential',$MTMPConfig.Proxy.Credential)
        }
    }

}
#endregion


#region: Export Module Members                                                           
Export-ModuleMember -Variable ModuleName
Export-ModuleMember -Variable MTMPConfig
Export-ModuleMember -Variable LrCaseStatus
Export-ModuleMember -Variable AssemblyList
Export-ModuleMember -Variable HttpMethod
Export-ModuleMember -Variable HttpContentType
Export-ModuleMember -Function $Includes["Public"].BaseName
#endregion