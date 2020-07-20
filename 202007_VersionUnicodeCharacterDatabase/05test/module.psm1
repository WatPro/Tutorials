function Get-UTF8ByteType { 
  Param ( 
    [System.Byte]$Byte
  );
  if(       ($Byte -band 0x80) -eq    0) {
    [System.Int16]1;
  } elseif (($Byte -band 0xC0) -eq 0x80) { 
    [System.Int16]0;
  } elseif (($Byte -band 0xE0) -eq 0xC0) { 
    [System.Int16]2;
  } elseif (($Byte -band 0xF0) -eq 0xE0) { 
    [System.Int16]3;
  } elseif (($Byte -band 0xF8) -eq 0xF0) { 
    [System.Int16]4;
  }
}
function Get-UTF8ByteValue {
  Param ( 
    [System.Byte]$Byte
  );
  switch( Get-UTF8ByteType -Byte $Byte ) { 
    0 { $Byte -band 0x3F }
    1 { $Byte            }
    2 { $Byte -band 0x1F }
    3 { $Byte -band 0x0F }
    4 { $Byte -band 0x07 }
  }
}
function Get-FileUTF8Bytes {
  Param ( 
    [System.IO.Stream]$Stream
  ); 
  [System.Byte[]]$Empty = @(); 
  [System.Int16]$Byte   = $Stream.ReadByte(); 
  if( $Byte -eq -1 ) {return $Empty;}
  [System.Int16]$type   = (Get-UTF8ByteType -Byte $Byte);
  if ( ($type -ge 5) -or ($type -le 0) ) {
    return $Empty;
  }
  [System.Int16]$vv     = (Get-UTF8ByteValue -Byte $Byte);
  [System.Byte[]]$bytes = @($vv); 
  if ( $type -eq 1 ) {
    return (,$bytes);
  }
  for ([System.Int16]$ii=2; $ii -le $type; $ii += 1) {
    [System.Int16]$Byte = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return $Empty;}
    [System.Int32]$vv     = (Get-UTF8ByteValue -Byte $Byte);
    $bytes += $vv; 
  }
  return (,$bytes);
}
function Get-UTF8Code {
  Param ( 
    [System.Byte[]]$Bytes
  );
  [System.Int32]$len = $Bytes.Length; 
  if ($len -le 0) {
    return [System.Int32]-1; 
  }
  [System.Int16]$type   = (Get-UTF8ByteType -Byte $Bytes[0]);
  if ($len -ne $type) {
    return [System.Int32]-1; 
  }
  for([System.Int32]$ii=1; $ii -lt $len; $ii += 1) {
    [System.Int16]$type = (Get-UTF8ByteType -Byte $Bytes[$ii]);
    if($type -ne 0) {
      return [System.Int32]-1; 
    }
  }
  [System.Int32]$code = 0;
  for([System.Int32]$ii=0; $ii -lt $len; $ii += 1) {
    $code *= 0x40; 
    [System.Int32]$vv = (Get-UTF8ByteValue -Byte $Bytes[$ii]);
    $code += $vv; 
  }
  return $code; 
}
Export-ModuleMember -Function Get-FileUTF8Bytes, Get-UTF8Code;
