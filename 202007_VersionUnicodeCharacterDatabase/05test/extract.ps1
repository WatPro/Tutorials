
Import-Module -Name './module.psm1' -Function 'Get-FileUTF8Bytes', 'Get-UTF8Code', 'Get-UTF8Bytes';

Get-ChildItem |
  Where-Object {
    $_.Extension -eq '.sample'
  } | 
  ForEach-Object -Process {
    [System.String]$BaseName  = $_.BaseName ; 
    [System.String]$FullName  = $_.FullName ; 
    [System.IO.StreamReader]$Reader = (
      New-Object -TypeName System.IO.StreamReader -ArgumentList "${FullName}"
    ); 
    [System.IO.Stream]$Stream = $Reader.BaseStream; 
    while($true) {
      [System.Byte[]]$Bytes = (Get-FileUTF8Bytes -Stream $Stream); 
      if( $Bytes.Length -le 0 ) {
        break;
      }
      [System.Int32]$Code   = (Get-UTF8Code -Bytes $Bytes);
       1 | 
       Select-Object -Property @{label='unicode';expression={${Code}}},
                               @{label='file';expression={$BaseName}};
    }
    $Reader.Close();
  } | 
  Where-Object {$_.unicode -ge 0x80} |
  Export-Csv -LiteralPath './statistics.tsv' -Delimiter "`t" -NoTypeInformation;

Get-ChildItem |
  Where-Object {
    $_.Extension -eq '.sample'
  } | 
  Select-String -Pattern '&#([1-9][0-9]{0,6});' -AllMatches |
  Foreach-Object -Process {
    [System.String]$filename = $_.Filename;
    $_.Matches.ForEach({$_.Value -replace '&#([1-9][0-9]{0,6});', '$1'}) | 
      Select-Object -Property @{label='unicode';expression={[System.Convert]::ToInt32($_);}}, 
                              @{label='file';expression={${filename};}};
  } | 
  Where-Object {$_.unicode -ge 0x80} |
  Export-Csv -LiteralPath './statistics2.tsv' -Delimiter "`t" -NoTypeInformation;

Get-ChildItem |
  Where-Object {
    $_.Extension -eq '.tsv'
  } | 
  ForEach-Object -Process {
    Import-Csv -Delimiter "`t" -LiteralPath $_.FullName |
    Select-Object -Property @{
        label      = 'unicode';
        expression = {[System.Convert]::ToInt32($_.unicode);}
      }; 
  } |
  Sort-Object -Property unicode -Unique |
  Select-Object -Property unicode, 
    @{
      label      ='utf8';
      expression = {(Get-UTF8Bytes -Unicode $_.unicode).ForEach({$_.toString('X2');});}
    } |
  Export-Csv -LiteralPath './table.txt' -Delimiter "`t" -NoTypeInformation;

