
- Table belows lists mapping for: Common Name ([CN](https://docs.microsoft.com/en-us/windows/win32/adschema/a-cn "Active Directory Schema")), [LDAP](https://tools.ietf.org/html/rfc4511 "Lightweight Directory Access Protocol") Display Name and Property Name (in PowerShell's [Active Directory](https://docs.microsoft.com/en-us/powershell/module/activedirectory/set-aduser "Set-ADUser cmdlet modifies the properties of an Active Directory user") module).


|    Common Name    | LDAP Display Name |   Property Name   | Size / Range-Upper |
|:----------------- |:----------------- |:----------------- | ------------------:|
| Object-Sid        | objectSid         | (objectSid)       |                  - |
| SAM-Account-Name  | sAMAccountName    | (SamAccountName)  |                 20 |
| Display-Name      | displayName       | DisplayName       |                256 |
| RDN               | name              | Name              |                255 |
| Given-Name        | givenName         | GivenName         |                 64 |
| Initials          | initials          | Initials          |                  6 |
| Surname           | sn                | Surname           |                 64 |
| Department        | department        | Department        |                 64 |
| Title             | title             | Title             |                 64 |
| Employee-ID       | employeeID        | EmployeeID        |                 16 |
| Employee-Number   | employeeNumber    | EmployeeNumber    |                512 |
| E-mail-Addresses  | mail              | EmailAddress      |                256 |
| Telephone-Number  | telephoneNumber   | OfficePhone       |                 64 |
| When-Created      | whenCreated       | (whenCreated)     |                  - |
| When-Changed      | whenChanged       | (whenChanged)     |                  - |
| Create-Time-Stamp | createTimeStamp   | (createTimeStamp) |                  - |
| Modify-Time-Stamp | modifyTimeStamp   | (modifyTimeStamp) |                  - |

