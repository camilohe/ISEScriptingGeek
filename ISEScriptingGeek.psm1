#requires -version 4.0

<#
A collection of add-ons for the Powershell 4.0 ISE
last updated August 17, 2015
#>

#dot source the scripts
. $psScriptRoot\New-CommentHelp.ps1
. $psScriptRoot\ConvertTo-TextFile.ps1
. $psScriptRoot\Convert-AliasDefinition.ps1
. $psScriptRoot\Convertall.ps1
. $psScriptRoot\ConvertFrom-Alias.ps1
. $psScriptRoot\Sign-ISEScript.ps1
. $psScriptRoot\Print-ISEFile.ps1
. $psScriptRoot\Convert-CodeToSnippet.ps1
. $psScriptRoot\Out-ISETab.ps1
. $psScriptRoot\Open-SelectedinISE.ps1
. $psScriptRoot\Convert-CommandToHash.ps1
. $psScriptRoot\Get-CommandMetadata.ps1
. $psScriptRoot\CycleISETabs.ps1
. $psScriptRoot\New-DSCResourceSnippet.ps1
. $psScriptRoot\New-PSCommand.ps1
. $psScriptRoot\New-PSDriveHere.ps1
. $psScriptRoot\Find-InFile.ps1
. $psScriptRoot\CIMScriptMaker.ps1
. $psScriptRoot\Convert-ISEComment.ps1
. $psScriptRoot\ConvertTo-CommentHelp.ps1
. $psScriptRoot\Get-ScriptComments.ps1
. $psScriptRoot\Get-ASTScriptProfile.ps1
. $psScriptRoot\Get-SearchResult.ps1
. $psScriptRoot\New-Inputbox.ps1
. $psScriptRoot\Bookmarks.ps1
. $psScriptRoot\Reload-ISEFile.ps1
. $psScriptRoot\Edit-Snippet.ps1
. $psScriptRoot\Copy-ToWord.ps1
. $psScriptRoot\CloseAllFiles.ps1
. $psScriptRoot\CurrentProjects.ps1

<#
Add an ISE Menu shortcut to save all open files.
This will only save files that have previously been saved
with a title. Anything that is untitled still needs
to be manually saved first.
#>

$saveall={
  $psise.CurrentPowerShellTab.files | 
  where {-Not ($_.IsUntitled)} | 
  foreach {
    $_.Save()
  }
}

#a function to display scripting about topics
Function Get-ScriptingHelp {
Param()
 Get-Help about_Scripting* | Select Name,Synopsis | 
 Out-GridView -Title "Select one or more help topics" -OutputMode Multiple |
 foreach { $_ | get-help -ShowWindow}
}

#a function to for parameters for the current script
#using Show-Command
Function Start-MyScript {
Param([string]$Path = $psise.currentfile.FullPath)
If (Test-path $Path) {
    Show-Command -Name $path
}
else {
    Write-Warning "No file found"
}

} #end function

#create a custom sub menu
$jdhit = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ISE Scripting Geek",$null,$null)
#create some child menus for better organization
$Book = $jdhit.Submenus.add("Bookmarks",$Null,$Null)
$convert = $jdhit.Submenus.Add("Convert",$Null,$null)
$files = $jdhit.Submenus.Add("Files",$Null,$null)
$work = $jdhit.submenus.Add("Work",$Null,$null)

#add my menu addons in sort of alphabetical order
$jdhit.submenus.Add("Add Help",{New-CommentHelp},"ALT+H") | Out-Null

$convert.submenus.Add("Convert All Aliases",{ConvertTo-Definition $psise.CurrentFile.Editor.SelectedText},$Null) | Out-Null
$convert.submenus.Add("Convert Help to Comment Help",{ConvertTo-CommentHelp},"Ctrl+Shift+H") | Out-Null

$convert.submenus.Add("Convert Code to Snippet",{Convert-CodetoSnippet -Text $psise.CurrentFile.Editor.SelectedText},"CTRL+ALT+S")

$convert.submenus.Add("Convert Selected to Region",{
$psise.CurrentFile.Editor.InsertText("#region`r`r$($psise.CurrentFile.Editor.SelectedText)`r`r#endregion")},$null)
$convert.submenus.Add("Convert Selected From Alias",{ConvertFrom-Alias},$Null) | Out-Null
$convert.submenus.Add("Convert Single Selected to Alias",{Convert-AliasDefinition $psise.CurrentFile.Editor.SelectedText -ToAlias},$Null) | Out-Null
$convert.submenus.Add("Convert Single Selected to Command",{Convert-AliasDefinition $psise.CurrentFile.Editor.SelectedText -ToDefinition},$Null) | Out-Null
$convert.Submenus.Add("Convert to lowercase",
{$psise.currentfile.editor.insertText($psise.CurrentFile.Editor.SelectedText.toLower())},"CTRL+ALT+L") | Out-Null
$convert.Submenus.Add("Convert to parameter hash",{Convert-CommandToHash},"Ctrl+ALT+H") | Out-Null
$convert.submenus.Add("Convert to text file",{ConvertTo-TextFile}, "ALT+T") | Out-Null
$convert.Submenus.Add("Convert to uppercase",{$psise.currentfile.editor.insertText($psise.CurrentFile.Editor.SelectedText.toUpper())},"CTRL+ALT+U") | Out-Null

$jdhit.Submenus.add("Create new DSC Resource Snippets",{Get-DSCResource | New-DSCResourceSnippet},$Null) | Out-Null
$jdhit.submenus.add("Edit your ISE profile",{
  If (Test-Path $Profile) {
    psedit $profile
  }
  else {
    write-warning "Cannot find $profile"
  }
     },$Null) | Out-Null
$convert.Submenus.Add("Convert to block comment",{ConvertTo-MultiLineComment},"Ctrl+Alt+B") | Out-Null

$convert.Submenus.Add("Convert from block comment",{ConvertFrom-MultiLineComment},"Ctrl+Alt+C") | Out-Null

$files.Submenus.Add("Close All Files",{CloseAllFiles},"Ctrl+Alt+F4") | Out-Null
$files.submenus.Add("Edit snippets",{Edit-Snippet},$Null) | Out-Null

$files.submenus.Add("Get Script Profile",{Get-ASTProfile},$Null) | Out-Null

$jdhit.submenus.Add("Get Scripting Help",{Get-ScriptingHelp},$Null) | Out-Null

$files.Submenus.add("Find in File",{Find-InFile},"Ctrl+Shift+F") | Out-Null

$jdhit.submenus.Add("Insert Datetime",{$psise.CurrentFile.Editor.InsertText(("{0} {1}" -f (get-date),(get-wmiobject win32_timezone -property StandardName).standardName))},"ALT+F5") | out-Null
$jdhit.submenus.Add("Insert Short Date",{$psISE.currentfile.editor.inserttext((Get-Date).ToShortDateString())},"ALT+F6") | out-Null
$jdhit.submenus.Add("Insert Short Time",{$psISE.currentfile.editor.inserttext((Get-Date).ToShortTimeString())},"ALT+F7") | out-Null

$jdhit.Submenus.add("New CIM Command",{New-CimCommand},$Null) | Out-Null
$files.submenus.Add("Open Current Script Folder",{Invoke-Item (split-path $psise.CurrentFile.fullpath)},"ALT+O") | Out-Null
$files.Submenus.Add("Open Selected File",{Open-SelectedISE},"Ctrl+Alt+F") | Out-Null
$files.Submenus.Add("Reload Selected File",{Reset-ISEFile},"Ctrl+Alt+R") | Out-Null

$jdhit.submenus.Add("Print Script",{Send-ToPrinter},"CTRL+ALT+P") | Out-Null
$jdhit.submenus.Add("Run Script",{Start-MyScript},"CTRL+SHIFT+Z") | Out-Null

$files.Submenus.Add("Save All Files",$saveall,"Ctrl+Shift+A") | Out-Null
$files.submenus.Add("Save File as ASCII",{$psISE.CurrentFile.Save([Text.Encoding]::ASCII)}, $null) | Out-Null

$jdhit.Submenus.Add("Search selected text with Bing",{Get-SearchResult -SearchEngine Bing},"Shift+Alt+B") | Out-Null
$jdhit.Submenus.Add("Search selected text with Google",{Get-SearchResult -SearchEngine Google},"Shift+Alt+G") | Out-Null
$jdhit.Submenus.Add("Send to Word",{Copy-ToWord},"Ctrl+Alt+W") | Out-Null
$jdhit.Submenus.Add("Send to Word Colorized",{Copy-ToWord -Colorized},$Null) # | Out-Null                
$jdhit.submenus.Add("Sign Script",{Write-Signature},$null) | Out-Null

$jdhit.Submenus.Add("Switch next tab",{Get-NextISETab},"Ctrl+ALT+T") | Out-Null

$jdhit.Submenus.Add("Use local help",{$psise.Options.UseLocalHelp = $True},$Null) | Out-Null
$jdhit.Submenus.Add("Use online help",{$psise.Options.UseLocalHelp = $False},$Null) | Out-Null

$book.Submenus.Add("Add ISE Bookmark",{Add-ISEBookmark},"Ctrl+Shift+N") | Out-Null
$book.Submenus.Add("Clear ISE Bookmarks",{del $MyBookmarks},"Ctrl+Shift+C") | Out-Null
$book.Submenus.Add("Get ISE Bookmark",{Get-ISEBookmark},"Ctrl+Shift+G") | Out-Null
$book.Submenus.Add("Open ISE Bookmark",{Open-ISEBookmark},"Ctrl+Shift+O") | Out-Null
$book.Submenus.Add("Remove ISE Bookmark",{Remove-ISEBookmark},"Ctrl+Shift+K") | Out-Null
$book.Submenus.Add("Update ISE Bookmark",{Update-ISEBookmark},"Ctrl+Shift+X") | Out-Null

$work.submenus.Add("Add current file to work",{Add-CurrentProject -List $currentProjectList},"CTRL+Alt+A") | Out-Null
$work.submenus.Add("Edit current work file",{Edit-CurrentProject -List $currentProjectList},"CTRL+Alt+E") | Out-Null
$work.submenus.Add("Open current work files",{Import-CurrentProject -List $currentProjectList},"CTRL+Alt+I") | Out-Null


#define some ISE specific variables
$MySnippets = "$Env:USERPROFILE\Documents\WindowsPowerShell\Snippets"
$MyModules = Join-Path -Path $home -ChildPath "documents\WindowsPowerShell\Modules"
$MyPowerShell = "$env:userprofile\Documents\WindowsPowerShell"
$MyBookmarks = Join-Path -path $myPowerShell -ChildPath "myISEBookmarks.csv"
$CurrentProjectList = Join-Path -Path $env:USERPROFILE\Documents\WindowsPowerShell -ChildPath "currentWork.txt"

Export-ModuleMember -Function * -Alias * -Variable MySnippets,MyModules,MyPowerShell,MyBookmarks,CurrentProjectList

