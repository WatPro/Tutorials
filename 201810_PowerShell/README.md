
## PowerShell
 
```PowerShell
Get-ChildItem -Path "TargetDir*" -Directory | Select-Object -Property FullName | ForEach-Object {Get-ChildItem -Path ($_.FullName+"/TargetFile*.txt") -File} | Where-Object {($_.CreationTime).Date -eq (Get-Date).Date} | Select-Object -Property FullName, DirectoryName, Name | ForEach-Object { Get-Content -Path $_.FullName -Encoding ASCII | Out-File -FilePath ($_.DirectoryName+"/result_"+$_.Name) -Encoding UTF8 }
```
