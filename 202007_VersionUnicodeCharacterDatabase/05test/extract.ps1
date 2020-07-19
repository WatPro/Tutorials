
Import-Module -Name './module.psm1' -Function 'Get-UTF8Code';

Get-ChildItem |
  Where-Object {
    $_.Extension -eq '.csv'
  } | 
  ForEach-Object -Process {
    [System.String]$BaseName  = $_.BaseName ; 
    [System.String]$FullName  = $_.FullName ; 
    [System.IO.StreamReader]$Reader = (
      New-Object -TypeName System.IO.StreamReader -ArgumentList "${FullName}"
    ); 
    [System.IO.Stream]$Stream = $Reader.BaseStream; 
    while($true) {
      [System.Int32]$Code = (Get-UTF8Code -Stream $Stream); 
      if( ${Code} -le 0 ) {
        break;
      }
      1 | 
      Select-Object -Property @{label='unicode';expression={${Code}}},
                              @{label='file';expression={$BaseName}};
    }
    $Reader.Close();
  } | 
  Where-Object {$_.unicode -ge 0x80} |
  Export-Csv -LiteralPath './statistics.tsv' -Delimiter "`t";

Import-Csv -Delimiter "`t" -LiteralPath './statistics.tsv' |
  Select-Object -Property @{
      label      = 'unicode';
      expression = {[System.Convert]::ToInt32($_.unicode);}
    } |
  Sort-Object -Property unicode -Unique;
