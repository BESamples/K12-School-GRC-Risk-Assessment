Get-ADGroup -SearchBase 'OU=Groups,OU=Northstar,DC=corp,DC=com' -Filter * |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize
