Function Get-InputEmailAddress {
    <#
    .SYNOPSIS 
        Determine if a user entered a valid Email Address
    .PARAMETER Value
        String to evaluate as an Email Address
    .EXAMPLE
        PS C:\> Get-InputIpAddress -Value firstname.lastname@domain.com -OldValue firstname.lastname@domain.com

        Value                          Valid Changed
        -----                          ----- -------
        firstname.lastname@domain.com  True   False
    .EXAMPLE
        PS C:\> Get-InputIpAddress -Value firstname.lastname@domain -OldValue lastname.firstname@domain.com

        Value Valid Changed
        ----- ----- -------
              False    True
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Value,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $OldValue
    )

    # Validation Regexes
    $ValidRegex = [regex]::new("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$")
    
    
    $Return = [PSCustomObject]@{
        Value = $null
        Valid = $false
        Changed = $false
    }


    if($Value -match $ValidRegex) {
        $Return.Valid = $true
        $Return.Value = $Value
    }


    # Is Value different than OldValue
    if ($Return.Value -ne $OldValue) {
        $Return.Changed = $true
    }
    
    return $Return
}
