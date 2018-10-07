
## PowerShell
 
```PowerShell
./prepare.ps1

$plan=(Get-ChildItem -Path "TargetDir*" -Directory | Select-Object -Property FullName | ForEach-Object {Get-ChildItem -Path ($_.FullName+"/TargetFile*.txt") -File} | Where-Object {($_.CreationTime).Date -eq (Get-Date).Date} | Select-Object -Property @{Name="Target"; Expression = {Join-Path -Path $_.DirectoryName -ChildPath $_.Name}}, @{Name="Destination"; Expression = {Join-Path -Path $_.DirectoryName -ChildPath ("result_"+$_.Name)}})
 
$plan
 
$plan | ForEach-Object { Get-Content -Path $_.Target -Encoding ASCII | Out-File -FilePath $_.Destination -Encoding UTF8 }
 

```
