
[System.Text.UTF8Encoding]$UTF8       = [System.Text.Encoding]::UTF8 ;
[System.Text.UnicodeEncoding]$Unicode = [System.Text.Encoding]::Unicode ;
Get-ChildItem |
  Where-Object {
    $_.Extension -eq '.sample'
  } | 
  ForEach-Object -Process {
    [System.String]$BaseName = $_.BaseName ; 
    [System.String]$FullName = $_.FullName ; 
    Get-Content -LiteralPath "${FullName}" -Encoding UTF8; 
  } | 
  ForEach-Object -Process {
    [System.String]$OneLine = $_ ; 
    [System.Int32]$Len      = $OneLine.Length; 
    for ([System.Int32]$ii = 0; $ii -lt $Len; $ii+=1) {
      [System.Char]$cc = [System.Char]$OneLine[$ii]; 
      [System.Int64]$integer_uni  = (
        $Unicode.GetBytes($cc) | 
        ForEach-Object -Begin {
          [System.Int64]$multi=1;[System.Int64]$code=0;
        } -Process {
          $code+=$_*$multi;$multi*=256
        } -End{$code}
      ); 
      [System.String]$string_utf8 = (
        ($UTF8.GetBytes($cc) | ForEach-Object -Process {$_.toString('X')}) -join ' '
      ); 
      1 | 
      Select-Object @{label='unicode';expression={$integer_uni}},
                    @{label='utf8';expression={$string_utf8}}, 
                    @{label='file';expression={$BaseName}}, 
                    @{label='character';expression={$cc}};
    }
  } | 
  Where-Object { $_.unicode -ge 0x80 } | 
  Export-Csv -LiteralPath './statistics.csv' -Encoding utf8; 
