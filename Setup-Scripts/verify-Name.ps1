Get-ADOrganizationalUnit -Filter * |
    Where-Object { $_.DistinguishedName -like '*OU=Northstar,*' } |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize
