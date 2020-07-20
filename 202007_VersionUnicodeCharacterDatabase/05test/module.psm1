function Get-UTF8ByteType { 
  Param ( 
    [System.Byte]$Byte
  );
  if(       ($Byte -band 0x80) -eq    0) {
    [System.Int32]1;
  } elseif (($Byte -band 0xC0) -eq 0x80) { 
    [System.Int32]0;
  } elseif (($Byte -band 0xE0) -eq 0xC0) { 
    [System.Int32]2;
  } elseif (($Byte -band 0xF0) -eq 0xE0) { 
    [System.Int32]3;
  } elseif (($Byte -band 0xF8) -eq 0xF0) { 
    [System.Int32]4;
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
  [System.Int16]$Byte1 = $Stream.ReadByte(); 
  if( $Byte1 -eq -1 ) {return [System.Byte[]]@();}
  [System.Int32]$type  = (Get-UTF8ByteType -Byte $Byte1);
  if ( ($type -ge 5) -or ($type -le 0) ) {
    return [System.Byte[]]@();
  }
  [System.Int32]$vv    = (Get-UTF8ByteValue -Byte $Byte1);
  [System.Byte[]]$bs   = @($vv); 
  if ( $type -eq 1 ) {
    return $bs; 
  }
  if ( $type -ge 2 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return [System.Byte[]]@();}
    [System.Int32]$vv     = (Get-UTF8ByteValue -Byte $Byte_p);
    $bs += $vv;
  } 
  if ( $type -ge 3 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return [System.Byte[]]@();}
    [System.Int32]$vv     = (Get-UTF8ByteValue -Byte $Byte_p);
    $bs += $vv;
  }
  if ( $type -ge 4 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return [System.Byte[]]@();}
    [System.Int32]$v      = (Get-UTF8ByteValue -Byte $Byte_p);
    $bs += $vv;
  }

  return $bs;
}
Export-ModuleMember -Function Get-UTF8Code;
