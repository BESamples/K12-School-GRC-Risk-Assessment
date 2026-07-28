# Rules of Engagement

## Purpose

These rules define the authorized testing boundaries for the Northstar High School GRC lab.

All testing must remain safe, controlled, documented, and limited to the simulated lab environment.

## Authorized Environment

Testing is authorized only against systems created for this project, including:

- The `northstar.local` Active Directory domain
- The Windows Server domain controller
- Lab Windows workstations
- The Ubuntu Wazuh server
- The Kali Linux testing system
- Simulated file shares
- Fictional user accounts
- Harmless test files

## Prohibited Targets

The following systems must not be tested:

- The school’s production network
- School-owned systems outside the assigned lab
- Real student or employee accounts
- Public websites or internet systems
- Personal devices not included in the lab
- Systems belonging to other students
- Any system without explicit authorization

## Permitted Activities

The following activities are permitted within the lab:

- Active Directory configuration
- User and group creation
- Group membership validation
- File and folder permission testing
- Group Policy configuration
- Windows event-log review
- Wazuh monitoring
- Sysmon testing
- File Integrity Monitoring
- Safe PowerShell activity
- Harmless YARA test files
- Account lockout testing
- Disabled-account validation
- Authorized vulnerability scanning
- Incident-response simulations
- Evidence collection

## Prohibited Activities

The following activities are not permitted:

- Use of real malware
- Ransomware execution
- Destructive scripts
- Denial-of-service testing
- Password spraying against real accounts
- Credential theft
- Social engineering
- Phishing real users
- Data destruction
- Testing outside the lab
- Publishing passwords or credentials
- Publishing sensitive school information

## Safety Requirements

All testing must use fictional data and harmless commands.

Before running a test:

1. Confirm the target is part of the authorized lab.
2. Confirm the test is non-destructive.
3. Confirm no real information is involved.
4. Record the purpose of the test.
5. Save evidence before the lab resets.

If a test causes unexpected system instability, testing must stop until the issue is reviewed.

## Account and Credential Handling

Passwords used in the lab must not be reused for personal, work, or school accounts.

The GitHub repository must not contain:

- Passwords
- Password hashes
- API keys
- Authentication tokens
- Private certificates
- Recovery keys
- Real email addresses
- Real student information
- Real employee information

Screenshots must be reviewed before upload to ensure no sensitive information is visible.

## Evidence Handling

Evidence may include:

- Screenshots
- PowerShell output
- Windows event logs
- Wazuh alerts
- Sysmon events
- Group membership records
- File permission results
- Configuration files
- Incident timelines

Each evidence item must be clearly labeled and connected to the related test, control, or finding.

Evidence should be saved before the four-hour lab reset.

## Testing Schedule

Testing may be completed across multiple lab sessions.

Because the environment resets approximately every four hours:

- Setup scripts may be used to rebuild the environment.
- Each completed section should be validated before moving forward.
- Evidence should be saved immediately after successful testing.
- Documentation should identify when a test was repeated in a new session.

## Stop Conditions

Testing must stop immediately if:

- The target is outside the authorized lab.
- A command may affect the school’s production network.
- Real student or employee information is discovered.
- The test causes unexpected damage or instability.
- Authorization is unclear.
- A test requires real malware or destructive activity.

## Reporting Requirements

Any identified issue must be documented with:

- A clear description
- The affected system or process
- Supporting evidence
- The potential risk
- A recommended corrective action
- A remediation priority

## Authorization Statement

This project is an educational simulation performed within an authorized school lab.

These rules do not grant permission to test any production, public, personal, or third-party system.
