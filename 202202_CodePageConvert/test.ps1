
Import-Module -Name .\iconv.psm1 -Verbose

[System.String]$FileIn  = '.\test.txt';
[System.String]$FileOut = '.\out.txt';

[System.Management.Automation.ScriptBlock]$iconv = (iconvGenerator -inCodePage 65001 -outCodePage 1200);

&$iconv -inFile "${FileIn}" -outFile "${FileOut}"

