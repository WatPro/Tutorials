
function iconvGenerator {
  param(
    [System.Int32]$inCodePage  = 65001,
    [System.Int32]$outCodePage = 65001
  );
  [System.Management.Automation.ScriptBlock]$iconv = {
    param(
      [System.String]$inFile,
      [System.String]$outFile
    );
    if ( ("${inFile}" -ne '') -and ("${outFile}" -ne '') ) {
      [System.IO.StreamReader]$streamin  = New-Object -TypeName System.IO.StreamReader -ArgumentList ("${inFile}",          [System.Text.Encoding]::GetEncoding(${inCodePage}), $true);
      [System.IO.StreamWriter]$streamout = New-Object -TypeName System.IO.StreamWriter -ArgumentList ("${outFile}", $false, [System.Text.Encoding]::GetEncoding(${outCodePage}));
      While( $streamin.Peek() -ge 0 ) {
        $streamout.Write( [System.Char]($streamin.Read()) ); 
      }
      $streamin.Close();
      $streamout.Close();
      ## https://docs.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
    }
  }.GetNewClosure();
  return $iconv;
}

Export-ModuleMember -Function iconvGenerator