Get-ADUser -SearchBase 'OU=Users,OU=Northstar,DC=corp,DC=com' -Filter * |
    Select-Object Name, SamAccountName, Enabled |
    Format-Table -AutoSize
