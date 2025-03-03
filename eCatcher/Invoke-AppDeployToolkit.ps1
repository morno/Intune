﻿<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

$adtSession = @{
    # App variables.
    AppVendor = 'HMS Industrial Networks SA'
    AppName = 'Ecatcher'
    AppVersion = ''
    AppArch = ''
    AppLang = ''
    AppRevision = ''
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-03-03'
    AppScriptAuthor = 'Jason Bergner'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = 'HMS Industrial Networks Ecatcher'

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}

function Install-ADTDeployment
{
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, Close Ecatcher With a 60 Second Countdown Before Automatically Closing
        Show-ADTInstallationWelcome -CloseProcesses 'Ecatcher' -CloseProcessesCountdown 60

        ## Show Progress Message (With a Message to Indicate the Application is Being Uninstalled)
        Show-ADTInstallationProgress -StatusMessage "Removing Any Existing Version of $($adtSession.AppName). Please Wait..."

        ## Remove Any Existing Version of Ecatcher
        Uninstall-ADTApplication -Name "Ecatcher" -ApplicationType MSI
  
        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        $certPath = Get-ChildItem -Path "$($adtSession.DirFiles)" -Include OpenVPN.cer -File -Recurse -ErrorAction SilentlyContinue
        $msiPath = Get-ChildItem -Path "$($adtSession.DirFiles)" -Include Ecatcher*.msi -File -Recurse -ErrorAction SilentlyContinue
        $transform = Get-ChildItem -Path "$($adtSession.DirFiles)" -Include *.mst -File -Recurse -ErrorAction SilentlyContinue

        If ($certPath.Exists -and $msiPath.Exists) {

        ## Import OpenVPN certificate to System 'Trusted Publishers' store.
        Write-ADTLogEntry -Message "Importing the OpenVPN certificate."
        Show-ADTInstallationProgress -StatusMessage "Importing the OpenVPN certificate. This may take some time. Please wait..."
        Start-ADTProcess -FilePath "certutil.exe" -ArgumentList "-f -addstore -enterprise TrustedPublisher `"$certPath`""
        Start-Sleep -Seconds 5

        ## Install Ecatcher
        If ($msiPath.Exists -and $transform.Exists)
        {
        Write-ADTLogEntry -Message "Found $($msiPath.FullName) and $($transform.FullName), now attempting to install $($adtSession.AppName)."
        Show-ADTInstallationProgress -StatusMessage "Installing $($adtSession.AppName). This may take some time. Please wait..."
        Start-ADTMsiProcess -Action Install -FilePath "$msiPath" -AdditionalArgumentList "TRANSFORMS=""$transform"""
        }
        ElseIf ($msiPath.Exists)
        {
        Write-ADTLogEntry -Message "Found $($msiPath.FullName), now attempting to install $($adtSession.AppName)."
        Show-ADTInstallationProgress -StatusMessage "Installing $($adtSession.AppName). This may take some time. Please wait..."
        Start-ADTMsiProcess -Action Install -FilePath "$msiPath"
        }

        } else {
        Write-ADTLogEntry -Message "OpenVPN (.cer) or MSI installer were not found. Installation aborted." -Severity 2
        Show-ADTInstallationPrompt -Message "OpenVPN (.cer) or MSI installer were not found. Installation aborted." -ButtonRightText "OK"
        }
    
        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    }

function Uninstall-ADTDeployment
{
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, Close Ecatcher With a 60 Second Countdown Before Automatically Closing
        Show-ADTInstallationWelcome -CloseProcesses 'Ecatcher' -CloseProcessesCountdown 60

        ## Show Progress Message (With a Message to Indicate the Application is Being Uninstalled)
        Show-ADTInstallationProgress -StatusMessage "Uninstalling the $($adtSession.AppName) Application. Please Wait..."

        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Uninstall Any Existing Version of Ecatcher
        Uninstall-ADTApplication -Name "Ecatcher" -ApplicationType MSI

        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"


    }

function Repair-ADTDeployment
{
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"


        ##*===============================================
        ##* REPAIR
        ##*===============================================
        $adtSession.InstallPhase = $adtSession.DeploymentType


        ##*===============================================
        ##* POST-REPAIR
        ##*===============================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"


    }


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}
