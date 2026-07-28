# Assumptions and Limitations

## Assumptions

The following assumptions apply to this assessment:

- Northstar High School is a fictional organization created for educational purposes.
- All users, systems, records, and incidents are simulated.
- The lab environment is authorized for testing.
- The simulated school represents a larger K-12 environment.
- A small representative sample of users is sufficient to test access-control processes.
- The Windows Server functions as the domain controller for the `northstar.local` domain.
- The Ubuntu virtual machine will host the Wazuh manager.
- Windows workstations will be used to test administrator, teacher, and student access.
- Kali Linux will only be used for authorized testing inside the lab.
- PowerShell scripts may be used to rebuild the environment consistently after each reset.

## Lab Reset Limitation

The school lab resets approximately every four hours.

Because of this limitation:

- Active Directory objects may need to be recreated.
- Security groups and memberships may need to be reapplied.
- Screenshots and logs must be saved before the lab resets.
- PowerShell automation will be used to reduce setup time.
- Testing may be completed across multiple lab sessions.

## User and System Limitations

The lab does not recreate the full size of a real school.

The environment uses:

- A limited number of fictional student accounts
- A limited number of teacher and administrative accounts
- One domain controller
- One or two Windows workstations
- One Ubuntu Wazuh server
- One Kali Linux testing system

The results are based on this representative sample and may not reflect every issue that could exist in a large school district.

## Data Limitations

No real student, employee, parent, or school information will be used.

Only fictional records will be created, including:

- Student names and identification numbers
- Grades and attendance records
- Employee information
- Administrative documents
- Security test files

Passwords, tokens, private IP addresses, and other sensitive information will not be published in the GitHub repository.

## Technical Limitations

Some controls may be simulated rather than fully implemented.

Examples may include:

- Backup and recovery testing
- Multi-factor authentication
- Email security
- Physical security
- Vendor risk management
- Cloud security
- Security awareness training
- Formal incident escalation

The project will focus primarily on controls that can be demonstrated using Active Directory, Windows, Wazuh, Sysmon, PowerShell, file permissions, and safe test files.

## Assessment Limitations

This project is not:

- A formal compliance audit
- A penetration test of a real school
- A legal determination of FERPA compliance
- A certification of security effectiveness
- A replacement for a professional risk assessment

The findings represent only the condition of the simulated lab at the time testing was performed.

## Evidence Limitations

Evidence may include screenshots, exported logs, configuration files, and PowerShell output.

Because the lab resets regularly, some evidence may be collected during different lab sessions. Each evidence file will be labeled clearly so it can be connected to the related control test or finding.
