# Orginal source from Sitecore Powershell Extension
param(
    [Parameter(Mandatory=$true)]
    [string]$FunctionName = "Get-Help",
    [Parameter(Mandatory=$true)]
    [string]$DocFolder
)

Write-Host "Processing $FunctionName to $DocFolder"

$builder = New-Object System.Text.StringBuilder

$carriage = "`r"
function FixString {
  param($in = '')
  if ($in -eq $null) {
    $in = ''
  }
  return $in.Trim().Trim('\n').Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace("\r","`r")
}

function FixExampleString {
  param($in = '')
  if ($in -eq $null) {
    $in = ''
  }
  return $in.Trim().Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace("`n","<br/>")
}

$c = Get-Help $FunctionName -Full

$builder.Append("") | Out-Null
$builder.Append("# $($c.Name)") | Out-Null
$builder.AppendLine(" ") | Out-Null
$builder.AppendLine(" ") | Out-Null
$builder.Append("$($c.synopsis)") | Out-Null
$builder.AppendLine(" ") | Out-Null
$builder.AppendLine(" ") | Out-Null
$builder.Append("## Syntax") | Out-Null
$builder.AppendLine(" ") | Out-Null

foreach($syntax in $c.syntax.syntaxItem) {
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("$($syntax.Name)") | Out-Null
    foreach($param in $syntax.parameter){
        $builder.Append(" ") | Out-Null
        if($param.required -eq "false"){
            $builder.Append("[") | Out-Null
        }
        if($param.position -ne "named"){
            $builder.Append("[-$($param.Name)]") | Out-Null
        } else {
            $builder.Append("-$($param.Name)") | Out-Null
        }
        if($param.parameterValue -ne $null -and $param.parameterValue -ne "SwitchParameter"){
            $builder.Append(" &lt;$($param.parameterValue)&gt;") | Out-Null
        }
        if($param.required -eq "false"){
            $builder.Append("]") | Out-Null
        }
    }
    $builder.AppendLine(" ") | Out-Null
}

if($c.Description) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("## Detailed Description") | Out-Null
    
    foreach($Description in $c.Description){
        $builder.AppendLine(" ") | Out-Null
        $builder.AppendLine(" ") | Out-Null
        $builder.Append("$(FixString($Description | out-string -width 20000))") | Out-Null
    }
}

$aliases = Get-Alias | Where-Object { $_.Definition -eq "$helpFor" } | % { $_.Name }

if ($aliases.Count -gt 0) {
    $builder.Append("## Aliases") | Out-Null
    $builder.AppendLine($carriage) | Out-Null
    $builder.Append("The following abbreviations are aliases for this cmdlet:  ") | Out-Null
    $builder.AppendLine($carriage) | Out-Null
    foreach($alias in $aliases) {
        $builder.Append("* $($alias)") | Out-Null
    }
}

# Parameters
$builder.AppendLine(" ") | Out-Null
$builder.AppendLine(" ") | Out-Null
$builder.Append("## Parameters") | Out-Null
foreach ($param in $c.parameters.parameter ) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("### -$($param.Name)&nbsp; &lt;$($param.type.Name)&gt;") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    foreach($Description in $param.Description) {
        $builder.Append("$(FixString($Description | out-string -width 2000))") | Out-Null
    }

    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
$builder.Append(
@"
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td>$($param.Aliases)</td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>$($param.Required)</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>$($param.Position)</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td>$($param.DefaultValue)</td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>$($param.PipelineInput)</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>$($param.Globbing)</td>
        </tr>
    </tbody>
</table>
"@) | Out-Null
}

# Input Type
if (($c.inputTypes | Out-String ).Trim().Length -gt 0) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("## Inputs") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("The input type is the type of the objects that you can pipe to the cmdlet.") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    foreach($inputType in $c.inputTypes.inputType){
        $builder.Append("$(FixString(($inputType.description.text -split '\r') | ForEach-Object { if($_.Trim()) { '* ' + $_.Trim() } } | Out-String  -width 2000))") | Out-Null
    }
    foreach($inputType in $c.inputTypes.inputType){
        $builder.Append("$(FixString(($inputType.type.name -split '\r') | ForEach-Object { if($_.Trim()) { '* ' + $_.Trim() } } | Out-String  -width 2000))") | Out-Null
    }
}
   
# Return Type
if (($c.returnValues | Out-String ).Trim().Length -gt 0) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("## Outputs") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("The output type is the type of the objects that the cmdlet emits.") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    foreach($returnValue in $c.returnValues.returnValue){
        $builder.Append("$(FixString(($returnValue.description.Text -split '\r') | ForEach-Object { if($_.Trim()) { '* ' + $_.Trim() } } | Out-String  -width 2000))") | Out-Null
        $builder.Append("$(FixString(($returnValue.type.name -split '\r') | ForEach-Object { if($_.Trim()) { '* ' + $_.Trim() } } | Out-String  -width 2000))") | Out-Null
    }
}
         
         
# Notes
if (($c.alertSet | Out-String).Trim().Length -gt 0) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("## Notes") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    foreach($alert in $c.alertSet.alert){
        $builder.Append("$(FixString($alert | out-string))") | Out-Null
    }
}

# Examples
if (($c.examples | Out-String).Trim().Length -gt 0) {
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.Append("## Examples") | Out-Null
    foreach ($example in $c.examples.example)     {

        $builder.AppendLine(" ") | Out-Null
        $builder.AppendLine(" ") | Out-Null
        $builder.Append("### $(FixString($example.title.Trim(('-',' '))))") | Out-Null
        $builder.AppendLine(" ") | Out-Null
        $builder.AppendLine(" ") | Out-Null
        if( $example.code -like '*json*' )
        {
            $builder.Append("$(FixString($example.code | out-string -Width 2000).Trim())") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append('```powershell  ') | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append("$(FixString($example.remarks | out-string -Width 2000).Trim())")  | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append('```') | Out-Null
        }
        else
        {
            $builder.Append("$(FixString($example.remarks | out-string -Width 2000).Trim())") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append('```powershell  ') | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append("$($example.code)") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.AppendLine(" ") | Out-Null
            $builder.Append('```') | Out-Null
        }
        
    }
}

#Related Topics
$builder.AppendLine(" ") | Out-Null
$builder.AppendLine(" ") | Out-Null
$links = $c.relatedLinks.navigationLink | Where-Object { $_.linkText }
if($links) {
    $builder.Append("## Related Topics") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    $builder.AppendLine(" ") | Out-Null
    foreach ($relatedLink in $links) {
        if($relatedLink.linkText.StartsWith('about') -eq $false) {
            if($relatedLink.uri){
               $builder.Append( "* <a href='$($relatedLink.uri)' target='_blank'>$($relatedLink.uri)</a>") | Out-Null
            } else {
                if($relatedLink.linkText -match 'http'){
                 $url = $relatedLink.linkText | select-string -pattern '\b(?:(?:https?|ftp|file)://|www\.|ftp\.)(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[A-Z0-9+&@#/%=~_|$])' | % { $_.Matches } | % { $_.Value } | select -first 1
                 $builder.Append("`r* <a href='$url' target='_blank'>$($relatedLink.linkText)</a><br/>") | Out-Null
                } else {
                 $internalCommand = $relatedLink.linkText
                 
                 if ($commandNames -contains $internalCommand) {
                    $builder.Append("`r* [$internalCommand](/appendix/commands/$internalCommand.md)") | Out-Null
                 }
                 else
                 {
                     $builder.Append("`r* $internalCommand") | Out-Null
                 }
                }
            }
        }
    }
}

if($hideOutput -eq $null){
    #Write-Output $builder.ToString() 
    $doc = Join-Path -Path $DocFolder -ChildPath "$FunctionName.md"

    $builder.ToString()  | Out-File -FilePath $doc
}