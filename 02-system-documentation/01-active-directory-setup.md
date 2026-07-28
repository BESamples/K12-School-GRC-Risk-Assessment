# Part 1: Active Directory Structure and User Provisioning

## Objective

The objective of this section was to create a small, representative Active Directory environment for the fictional Northstar High School.

The simulated school represents a larger organization, but only a limited number of test accounts were created because the school lab resets every four hours.

This approach allows access-control and account-management controls to be tested without creating hundreds of student accounts.

## Environment

- Domain: `northstar.local`
- Domain Controller: Windows Server
- Management Tool: Active Directory Users and Computers
- Organization: Northstar High School
- Environment Type: Authorized school lab simulation

## Organizational Unit Structure

The following Organizational Unit structure was created:

```text
Northstar
├── Computers
│   ├── Servers
│   ├── Staff Workstations
│   └── Student Workstations
│
├── Groups
│
└── Users
    ├── Administration
    ├── Disabled Users
    ├── IT
    ├── Service Accounts
    ├── Students
    └── Teachers
