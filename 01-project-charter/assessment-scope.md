# Assessment Scope

## Assessment Name

Northstar High School Cybersecurity Risk and Control Assessment

## Purpose

The purpose of this assessment is to evaluate selected cybersecurity controls within a simulated K-12 school environment.

The assessment focuses on identity and access management, system monitoring, data protection, incident response, and risk management.

## In-Scope Environment

The assessment includes the following authorized lab systems:

| System | Purpose |
|---|---|
| Windows Server Domain Controller | Active Directory, DNS, user accounts, security groups, and Group Policy |
| Windows Workstation | Simulated administrative, teacher, and student access testing |
| Ubuntu Server | Planned Wazuh security monitoring server |
| Kali Linux | Authorized testing and validation within the isolated lab |
| Active Directory Domain | User provisioning, group membership, access control, and account management |
| Simulated File Shares | Student records, staff records, and general shared files |

## In-Scope Users and Roles

The assessment uses a representative sample of fictional accounts:

- IT administrators
- School administrators
- Teachers
- Students
- Disabled former employees

The simulated school represents a larger organization, but only a small number of accounts are required for control testing.

## In-Scope Security Areas

The assessment will evaluate selected controls related to:

- User account provisioning
- User account disabling and offboarding
- Role-based access control
- Least privilege
- Security group membership
- File and folder permissions
- Logging and monitoring
- File integrity monitoring
- PowerShell activity
- Malware detection using safe test files
- Incident-response procedures
- Risk identification and remediation tracking

## In-Scope Information

Only fictional information will be used, including:

- Simulated student names
- Simulated student identification numbers
- Fictional grades and attendance records
- Simulated employee records
- Test administrative documents
- Harmless security-testing files

No real student, employee, customer, or organizational data will be used.

## Out-of-Scope Activities

The following activities are outside the scope of this project:

- Testing the school’s production network
- Accessing real student or employee records
- Testing systems without authorization
- Using real malware
- Destructive security testing
- Denial-of-service testing
- Password attacks against real accounts
- Social-engineering attacks
- Physical security testing
- Legal or formal compliance certification

## Assessment Boundaries

All technical testing must remain within the authorized school lab environment.

The lab resets approximately every four hours. PowerShell scripts may be used to rebuild the simulated environment quickly and consistently.

Testing will use safe commands, fictional accounts, and harmless test files.

## Assessment Period

The assessment will be completed in multiple lab sessions because of the four-hour reset limitation.

Evidence will be collected during each completed section and stored in the GitHub project repository.

## Scope Limitation

This project is an educational GRC simulation. It is not a formal audit of a real school or school district.

The findings represent only the condition of the simulated environment at the time each test is performed.
