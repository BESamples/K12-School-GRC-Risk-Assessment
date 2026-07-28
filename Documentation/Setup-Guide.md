# Northstar Active Directory Lab Setup Guide

## Purpose

This guide explains how to deploy the Northstar simulated school Active Directory environment.

The lab creates organizational units, users, security groups, group memberships, a disabled former employee account, and a service account for GRC testing.

## Lab Requirements

- Windows Server 2019
- Active Directory Domain Services installed
- Server configured as a domain controller
- PowerShell 5.1 or later
- Active Directory PowerShell module
- Domain Administrator access

## Lab Domain

The lab was tested using:

```text
corp.com
