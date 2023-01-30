<#
Title: FUNCTION - TEMPLATE
Author: [Author's Name Here]
Created: YYYY-MM-DD
Last Updated: YYYY-MM-DD

.SYNOPSIS
	- A brief description of the function or script. This keyword can be used only once in each topic.

.DESCRIPTION:
    - A detailed description of the function or script. This keyword can be used only once in each topic.

.INPUTS
	- The .NET types of objects that can be piped to the function or script. You can also include a description of the input objects. Write 'None' if there are no inputs.

.OUTPUTS
	- The .NET type of the objects that the cmdlet returns. You can also include a description of the returned objects. Write 'None' if there are no inputs.

.PARAMATER Param1
	- The description of a parameter. Add a .PARAMETER keyword for each parameter in the function or script syntax.
	- Type the parameter name on the same line as the .PARAMETER keyword. Type the parameter description on the lines following the .PARAMETER keyword. Windows PowerShell interprets all text between the .PARAMETER line and the next keyword or the end of the comment block as part of the parameter description. The description can include paragraph breaks.

	# .PARAMETER  <Parameter-Name>
	- The Parameter keywords can appear in any order in the comment block, but the function or script syntax determines the order in which the parameters (and their descriptions) appear in help topic. To change the order, change the syntax.
	- You can also specify a parameter description by placing a comment in the function or script syntax immediately before the parameter variable name. For this to work, you must also have a comment block with at least one keyword.
	- If you use both a syntax comment and a .PARAMETER keyword, the description associated with the .PARAMETER keyword is used, and the syntax comment is ignored.
		<#
		#.SYNOPSIS
			Short description here
		# >
		function Verb-Noun {
			[CmdletBinding()]
			param (
				# This is the same as .Parameter
				[string]$Computername
			)
			# Verb the Noun on the computer
		}

.PARAMATER Param2
	- Comments/Description of this parameter

.EXAMPLE
	A sample command that uses the function or script, optionally followed by sample output and a description. Repeat this keyword for each example.
	Get-PublicScript_Template -Param1 <INPUT> -Param2 <INPUT>

.NOTES
	- Additional information about the function or script.

.LINK
	https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.3
	- The name of a related topic. The value appears on the line below the ".LINK" keyword and must be preceded by a comment symbol # or included in the comment block.
	- Repeat the .LINK keyword for each related topic.
	- This content appears in the Related Links section of the help topic.
	- The .Link keyword content can also include a Uniform Resource Identifier (URI) to an online version of the same help topic. The online version opens when you use the Online parameter of Get-Help. The URI must begin with "http" or "https".

.COMPONENT
	- The name of the technology or feature that the function or script uses, or to which it is related. The Component parameter of Get-Help uses this value to filter the search results returned by Get-Help.
	
.ROLE
	- The name of the user role for the help topic. The Role parameter of Get-Help uses this value to filter the search results returned by Get-Help.
	
.FUNCTIONALITY
	- The keywords that describe the intended use of the function. The Functionality parameter of Get-Help uses this value to filter the search results returned by Get-Help.

.FORWARDHELPTARGETNAME
	- Redirects to the help topic for the specified command. You can redirect users to any help topic, including help topics for a function, script, cmdlet, or provider.

	# .FORWARDHELPTARGETNAME <Command-Name>

.FORWARDHELPCATEGORY
	- Specifies the help category of the item in .ForwardHelpTargetName. Valid values are Alias, Cmdlet, HelpFile, Function, Provider, General, FAQ, Glossary, ScriptCommand, ExternalScript, Filter, or All. Use this keyword to avoid conflicts when there are commands with the same name.
	
	# .FORWARDHELPCATEGORY <Category>

.REMOTEHELPRUNSPACE
	- Specifies a session that contains the help topic. Enter a variable that contains a PSSession object. This keyword is used by the Export-PSSession cmdlet to find the help topics for the exported commands.
	
	# .REMOTEHELPRUNSPACE <PSSession-variable>

.EXTERNALHELP
	Specifies an XML-based help file for the script or function.

	# .EXTERNALHELP <XML Help File>

	- The .ExternalHelp keyword is required when a function or script is documented in XML files. Without this keyword, Get-Help cannot find the XML-based help file for the function or script.
	- The .ExternalHelp keyword takes precedence over other comment-based help keywords. If .ExternalHelp is present, Get-Help does not display comment-based help, even if it cannot find a help topic that matches the value of the .ExternalHelp keyword.
	- If the function is exported by a module, set the value of the .ExternalHelp keyword to a filename without a path. Get-Help looks for the specified file name in a language-specific subdirectory of the module directory. There are no requirements for the name of the XML-based help file for a function, but a best practice is to use the following format:
	
	<ScriptModule.psm1>-help.xml

	- If the function is not included in a module, include a path to the XML-based help file. If the value includes a path and the path contains UI-culture-specific subdirectories, Get-Help searches the subdirectories recursively for an XML file with the name of the script or function in accordance with the language fallback standards established for Windows, just as it does in a module directory.

	- For more information about the cmdlet help XML-based help file format, see How to Write Cmdlet Help.
<##>

function Get-PublicScript_Template {
    [CmdletBinding()]
    param(
        
        [Parameter()] [string]$param1, # Parameter 1
        [Parameter()] [string]$param2 # Parameter 2
    )
	
	if ($param1) { "..." }# Parameter 1
	if (!$param2) { "..." }# Parameter 2
	
	return
}