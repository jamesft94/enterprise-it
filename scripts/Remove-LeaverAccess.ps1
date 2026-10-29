<#
.SYNOPSIS
    Finishes offboarding a leaver: signs them out everywhere and removes company data
    from their Intune-managed devices.

.DESCRIPTION
    Terraform disables the account (status = "leaver" in users.csv) and the dynamic groups
    remove licences and app access. This script does the two things Terraform can't:
      1. Revokes all sign-in sessions, so open apps stop working now, not in an hour.
      2. Retires the person's Intune devices (removes company apps and data; a personal
         phone stays usable).

    Run it with -WhatIf first to see what it would do.

.EXAMPLE
    ./Remove-LeaverAccess.ps1 -UserPrincipalName ingrid.bakken@contoso.onmicrosoft.com -WhatIf
    ./Remove-LeaverAccess.ps1 -UserPrincipalName ingrid.bakken@contoso.onmicrosoft.com

.NOTES
    Requires: Install-Module Microsoft.Graph -Scope CurrentUser
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$UserPrincipalName
)

$ErrorActionPreference = 'Stop'

Connect-MgGraph -NoWelcome -Scopes @(
    'User.Read.All'
    'User.RevokeSessions.All'
    'DeviceManagementManagedDevices.Read.All'
    'DeviceManagementManagedDevices.PrivilegedOperations.All'
)

$user = Get-MgUser -UserId $UserPrincipalName -Property Id, DisplayName, AccountEnabled

# Safety check: only offboard someone Terraform has already disabled.
if ($user.AccountEnabled) {
    Write-Warning "$($user.DisplayName) is still enabled. Set status to 'leaver' in users.csv and apply first."
    return
}

if ($PSCmdlet.ShouldProcess($user.DisplayName, 'Revoke all sign-in sessions')) {
    Revoke-MgUserSignInSession -UserId $user.Id | Out-Null
    Write-Output "Signed $($user.DisplayName) out of all sessions."
}

$devices = Get-MgDeviceManagementManagedDevice -Filter "userPrincipalName eq '$UserPrincipalName'"
if (-not $devices) {
    Write-Output 'No Intune-managed devices found.'
}

foreach ($device in $devices) {
    $label = "$($device.DeviceName) ($($device.OperatingSystem))"
    if ($PSCmdlet.ShouldProcess($label, 'Retire Intune device')) {
        Invoke-MgRetireDeviceManagementManagedDevice -ManagedDeviceId $device.Id
        Write-Output "Retire sent to $label."
    }
}
