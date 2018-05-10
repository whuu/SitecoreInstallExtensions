#
# Invoke_EnsureJRETask.ps1
#
Set-StrictMode -Version 2.0

#Java SE Runtime Environment
Function Invoke-EnsureJRETask {
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		[string]$JavaPackagePath
	)

	$javaHome = [environment]::GetEnvironmentVariable("JAVA_HOME",[EnvironmentVariableTarget]::Machine)

	if($pscmdlet.ShouldProcess($javaHome, "Verify if JavaRE is installed"))
    {
		if( $javaHome -eq $null)
		{
			Write-Warning "Java is not installed (Solr requires JavaRE)"
 
			$MSIArguments = @(
				"/s"
			)
  
			Write-Host "Start installing Java: $JavaPackagePath"  

			if( -not (Test-Path -Path $JavaPackagePath ) ) { Write-Error "$JavaPackagePath not exists!"  return}
      
			Start-Process $JavaPackagePath -ArgumentList $MSIArguments -Wait -NoNewWindow
			
			$items = @()
			$items += Get-ChildItem -Path $env:ProgramFiles -Filter "java.exe" -Recurse -ErrorAction SilentlyContinue -ErrorVariable searchError
			
			if( $items.Count -eq 1 )
			{
				$javaHome  = Split-Path -Parent $items.Directory.FullName
			}
			else
			{
				$javaPath = $items | Out-GridView -PassThru  
				$javaHome  = Split-Path -Parent $javaPath.Directory.FullName
			}
			
			[environment]::SetEnvironmentVariable("JAVA_HOME",$javaHome,[EnvironmentVariableTarget]::Machine)   
			Write-Verbose "JAVA already installed $javaHome"
		}
		else
		{
			$message = "JAVA already installed $javaHome" 
			Write-Host $message  
		}
	}
}

Export-ModuleMember Invoke-EnsureJRETask
