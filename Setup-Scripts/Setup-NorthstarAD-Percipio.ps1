#requires -RunAsAdministrator
#requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Builds the Northstar High School Active Directory lab inside the
    school-provided corp.com domain.

.DESCRIPTION
    This script creates the Northstar OU structure, role-based security
    groups, fictional users, group memberships, and a disabled former
    employee account.

    It does NOT:
      - Create a new domain or forest
      - Promote a domain controller
      - Move or reset the workstation computer account
      - Create a Wazuh service account
      - Add any user to Domain Admins

    The script is rerunnable and will update existing Northstar objects
    instead of creating duplicates.

.EXAMPLE
    .\Setup-NorthstarAD-Percipio.ps1

.EXAMPLE
    .\Setup-NorthstarAD-Percipio.ps1 -ResetExistingPasswords

.EXAMPLE
    .\Setup-NorthstarAD-Percipio.ps1 -ForcePasswordChangeAtNextLogon
#>

[CmdletBinding()]
param(
    [securestring]$DefaultPassword,
    [switch]$ForcePasswordChangeAtNextLogon,
    [switch]$ResetExistingPasswords
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedDomain = 'corp.com'

function Write-Step {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Ensure-OU {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $distinguishedName = "OU=$Name,$Path"
    $existing = Get-ADOrganizationalUnit `
        -Identity $distinguishedName `
        -ErrorAction SilentlyContinue

    if (-not $existing) {
        New-ADOrganizationalUnit `
            -Name $Name `
            -Path $Path `
            -ProtectedFromAccidentalDeletion $false |
            Out-Null

        Write-Host "Created OU: $distinguishedName" -ForegroundColor Green
    }
    else {
        Write-Host "OU already exists: $distinguishedName" -ForegroundColor DarkGray
    }

    return $distinguishedName
}

function Ensure-Group {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $existing = Get-ADGroup `
        -Filter "SamAccountName -eq '$Name'" `
        -ErrorAction SilentlyContinue

    if (-not $existing) {
        New-ADGroup `
            -Name $Name `
            -SamAccountName $Name `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $Path `
            -Description $Description |
            Out-Null

        Write-Host "Created group: $Name" -ForegroundColor Green
    }
    else {
        Set-ADGroup `
            -Identity $existing `
            -Description $Description

        Write-Host "Group already exists: $Name" -ForegroundColor DarkGray
    }
}

function Ensure-User {
    param(
        [Parameter(Mandatory)]
        [string]$GivenName,

        [Parameter(Mandatory)]
        [string]$Surname,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string]$SamAccountName,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Description,

        [bool]$Enabled = $true,
        [bool]$ChangePasswordAtLogon = $false
    )

    $userPrincipalName = "$SamAccountName@$($script:Domain.DNSRoot)"

    $existing = Get-ADUser `
        -Filter "SamAccountName -eq '$SamAccountName'" `
        -Properties Enabled `
        -ErrorAction SilentlyContinue

    if (-not $existing) {
        New-ADUser `
            -Name $DisplayName `
            -GivenName $GivenName `
            -Surname $Surname `
            -DisplayName $DisplayName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $userPrincipalName `
            -Path $Path `
            -Description $Description `
            -AccountPassword $script:DefaultPassword `
            -Enabled $Enabled `
            -ChangePasswordAtLogon $ChangePasswordAtLogon

        Write-Host "Created user: $SamAccountName ($DisplayName)" -ForegroundColor Green
    }
    else {
        $currentParent = ($existing.DistinguishedName -split ',', 2)[1]

        if ($currentParent -ne $Path) {
            Move-ADObject `
                -Identity $existing.DistinguishedName `
                -TargetPath $Path

            Write-Host "Moved $SamAccountName to $Path" -ForegroundColor Yellow
        }

        Set-ADUser `
            -Identity $SamAccountName `
            -GivenName $GivenName `
            -Surname $Surname `
            -DisplayName $DisplayName `
            -UserPrincipalName $userPrincipalName `
            -Description $Description

        if ($ResetExistingPasswords) {
            Set-ADAccountPassword `
                -Identity $SamAccountName `
                -Reset `
                -NewPassword $script:DefaultPassword

            Write-Host "Reset password for: $SamAccountName" -ForegroundColor Yellow
        }

        if ($Enabled) {
            Enable-ADAccount -Identity $SamAccountName

            Set-ADUser `
                -Identity $SamAccountName `
                -ChangePasswordAtLogon $ChangePasswordAtLogon
        }
        else {
            Disable-ADAccount -Identity $SamAccountName
        }

        Write-Host "Updated existing user: $SamAccountName" -ForegroundColor DarkGray
    }
}

function Ensure-GroupMembership {
    param(
        [Parameter(Mandatory)]
        [string]$User,

        [Parameter(Mandatory)]
        [string]$Group
    )

    $alreadyMember = Get-ADGroupMember `
        -Identity $Group `
        -ErrorAction Stop |
        Where-Object { $_.SamAccountName -eq $User }

    if (-not $alreadyMember) {
        Add-ADGroupMember `
            -Identity $Group `
            -Members $User

        Write-Host "Added $User to $Group" -ForegroundColor Green
    }
    else {
        Write-Host "$User is already in $Group" -ForegroundColor DarkGray
    }
}

Import-Module ActiveDirectory

try {
    $script:Domain = Get-ADDomain
}
catch {
    throw 'Run this script on the Percipio Windows Server 2019 domain controller with the Active Directory module available.'
}

if ($script:Domain.DNSRoot -ne $ExpectedDomain) {
    throw "Safety check failed. This script is intended for '$ExpectedDomain', but the current domain is '$($script:Domain.DNSRoot)'."
}

if (-not $DefaultPassword) {
    $DefaultPassword = Read-Host `
        'Enter the temporary password for the Northstar lab accounts' `
        -AsSecureString
}

$script:DefaultPassword = $DefaultPassword

Write-Host "`nNorthstar Percipio lab setup" -ForegroundColor Yellow
Write-Host "Domain: $($script:Domain.DNSRoot)" -ForegroundColor Yellow
Write-Host "This script will not modify the workstation computer account." -ForegroundColor Yellow

Write-Step 'Creating organizational units'

$domainDN = $script:Domain.DistinguishedName

$ouNorthstar = Ensure-OU -Name 'Northstar' -Path $domainDN

$ouUsers = Ensure-OU -Name 'Users' -Path $ouNorthstar
$ouIT = Ensure-OU -Name 'IT' -Path $ouUsers
$ouAdministration = Ensure-OU -Name 'Administration' -Path $ouUsers
$ouTeachers = Ensure-OU -Name 'Teachers' -Path $ouUsers
$ouStudents = Ensure-OU -Name 'Students' -Path $ouUsers
$null = Ensure-OU -Name 'Service Accounts' -Path $ouUsers
$ouDisabledUsers = Ensure-OU -Name 'Disabled Users' -Path $ouUsers

$ouComputers = Ensure-OU -Name 'Computers' -Path $ouNorthstar
$null = Ensure-OU -Name 'Servers' -Path $ouComputers
$null = Ensure-OU -Name 'Staff Workstations' -Path $ouComputers
$null = Ensure-OU -Name 'Student Workstations' -Path $ouComputers

$ouGroups = Ensure-OU -Name 'Groups' -Path $ouNorthstar

Write-Step 'Creating role-based security groups'

$groups = @(
    @{
        Name = 'GG_IT_Admins'
        Description = 'Northstar IT administrative users'
    },
    @{
        Name = 'GG_School_Admins'
        Description = 'Northstar principal, registrar, and administrative staff'
    },
    @{
        Name = 'GG_Teachers'
        Description = 'Northstar teaching staff'
    },
    @{
        Name = 'GG_Students'
        Description = 'Northstar student users'
    },
    @{
        Name = 'GG_StudentRecords_Read'
        Description = 'Read-only access to simulated Northstar student records'
    },
    @{
        Name = 'GG_StudentRecords_Modify'
        Description = 'Modify access to simulated Northstar student records'
    },
    @{
        Name = 'GG_StaffRecords_Access'
        Description = 'Access to simulated Northstar employee records'
    },
    @{
        Name = 'GG_SharedDrive_Access'
        Description = 'Access to the general Northstar shared drive'
    }
)

foreach ($group in $groups) {
    Ensure-Group `
        -Name $group.Name `
        -Path $ouGroups `
        -Description $group.Description
}

Write-Step 'Creating IT accounts'

Ensure-User `
    -GivenName 'Jordan' `
    -Surname 'Lee' `
    -DisplayName 'Jordan Lee' `
    -SamAccountName 'jlee' `
    -Path $ouIT `
    -Description 'Northstar IT Administrator' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Alex' `
    -Surname 'Morgan' `
    -DisplayName 'Alex Morgan' `
    -SamAccountName 'amorgan' `
    -Path $ouIT `
    -Description 'Northstar IT Support Specialist' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Write-Step 'Creating administrative staff accounts'

Ensure-User `
    -GivenName 'Emily' `
    -Surname 'Carter' `
    -DisplayName 'Emily Carter' `
    -SamAccountName 'ecarter' `
    -Path $ouAdministration `
    -Description 'Northstar Principal' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Lisa' `
    -Surname 'Hernandez' `
    -DisplayName 'Lisa Hernandez' `
    -SamAccountName 'lhernandez' `
    -Path $ouAdministration `
    -Description 'Northstar Registrar' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Marcus' `
    -Surname 'Turner' `
    -DisplayName 'Marcus Turner' `
    -SamAccountName 'mturner' `
    -Path $ouAdministration `
    -Description 'Northstar School Counselor' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Write-Step 'Creating teacher accounts'

Ensure-User `
    -GivenName 'David' `
    -Surname 'Nguyen' `
    -DisplayName 'David Nguyen' `
    -SamAccountName 'dnguyen' `
    -Path $ouTeachers `
    -Description 'Northstar Teacher' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Sarah' `
    -Surname 'Brooks' `
    -DisplayName 'Sarah Brooks' `
    -SamAccountName 'sbrooks' `
    -Path $ouTeachers `
    -Description 'Northstar Teacher' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Kevin' `
    -Surname 'Hall' `
    -DisplayName 'Kevin Hall' `
    -SamAccountName 'khall' `
    -Path $ouTeachers `
    -Description 'Northstar Teacher' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Write-Step 'Creating student accounts'

Ensure-User `
    -GivenName 'Taylor' `
    -Surname 'Adams' `
    -DisplayName 'Taylor Adams' `
    -SamAccountName 'student1001' `
    -Path $ouStudents `
    -Description 'Northstar Student' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Cameron' `
    -Surname 'Reed' `
    -DisplayName 'Cameron Reed' `
    -SamAccountName 'student1002' `
    -Path $ouStudents `
    -Description 'Northstar Student' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Riley' `
    -Surname 'Lewis' `
    -DisplayName 'Riley Lewis' `
    -SamAccountName 'student1003' `
    -Path $ouStudents `
    -Description 'Northstar Student' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Jordan' `
    -Surname 'Price' `
    -DisplayName 'Jordan Price' `
    -SamAccountName 'student1004' `
    -Path $ouStudents `
    -Description 'Northstar Student' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Ensure-User `
    -GivenName 'Avery' `
    -Surname 'Scott' `
    -DisplayName 'Avery Scott' `
    -SamAccountName 'student1005' `
    -Path $ouStudents `
    -Description 'Northstar Student' `
    -ChangePasswordAtLogon $ForcePasswordChangeAtNextLogon.IsPresent

Write-Step 'Creating the disabled former-employee account'

Ensure-User `
    -GivenName 'Former' `
    -Surname 'Teacher' `
    -DisplayName 'Former Teacher' `
    -SamAccountName 'former.teacher' `
    -Path $ouDisabledUsers `
    -Description 'Disabled Northstar former employee test account' `
    -Enabled $false `
    -ChangePasswordAtLogon $false

Write-Step 'Applying group memberships'

$memberships = @{
    'jlee'        = @('GG_IT_Admins')
    'amorgan'     = @('GG_IT_Admins')
    'ecarter'     = @('GG_School_Admins', 'GG_StudentRecords_Read')
    'lhernandez'  = @('GG_School_Admins', 'GG_StudentRecords_Modify')
    'mturner'     = @('GG_School_Admins', 'GG_StudentRecords_Read')
    'dnguyen'     = @('GG_Teachers', 'GG_StudentRecords_Read', 'GG_SharedDrive_Access')
    'sbrooks'     = @('GG_Teachers', 'GG_StudentRecords_Read', 'GG_SharedDrive_Access')
    'khall'       = @('GG_Teachers', 'GG_StudentRecords_Read', 'GG_SharedDrive_Access')
    'student1001' = @('GG_Students', 'GG_SharedDrive_Access')
    'student1002' = @('GG_Students', 'GG_SharedDrive_Access')
    'student1003' = @('GG_Students', 'GG_SharedDrive_Access')
    'student1004' = @('GG_Students', 'GG_SharedDrive_Access')
    'student1005' = @('GG_Students', 'GG_SharedDrive_Access')
}

foreach ($user in $memberships.Keys) {
    foreach ($group in $memberships[$user]) {
        Ensure-GroupMembership `
            -User $user `
            -Group $group
    }
}

Write-Step 'Validating the Northstar build'

$createdUsers = Get-ADUser `
    -SearchBase $ouUsers `
    -Filter * `
    -Properties Enabled, Description |
    Select-Object `
        SamAccountName,
        Name,
        Enabled,
        Description,
        DistinguishedName |
    Sort-Object SamAccountName

$reportDirectory = if ($PSScriptRoot) {
    $PSScriptRoot
}
else {
    [Environment]::GetFolderPath('Desktop')
}

$reportPath = Join-Path `
    $reportDirectory `
    "Northstar-AD-Build-$((Get-Date).ToString('yyyyMMdd-HHmmss')).csv"

$createdUsers |
    Export-Csv `
        -Path $reportPath `
        -NoTypeInformation

Write-Host "`nNorthstar Percipio lab setup is complete." -ForegroundColor Green
Write-Host "Domain: $($script:Domain.DNSRoot)"
Write-Host "Users found under the Northstar OU: $($createdUsers.Count)"
Write-Host "Validation report: $reportPath"
Write-Host "Disabled account test: former.teacher" -ForegroundColor Yellow
Write-Host "The workstation computer account was not moved or modified." -ForegroundColor Yellow
