function Get-UTF8ByteType { 
  Param ( 
    [System.Byte]$Byte
  );
  if(       ($Byte -band 0b010000000) -eq 0) {
    [System.Int32]1;
  } elseif (($Byte -band 0b011000000) -eq 0b010000000) { 
    [System.Int32]0;
  } elseif (($Byte -band 0b011100000) -eq 0b011000000) { 
    [System.Int32]2;
  } elseif (($Byte -band 0b011110000) -eq 0b011100000) { 
    [System.Int32]3;
  } elseif (($Byte -band 0b011111000) -eq 0b011110000) { 
    [System.Int32]4;
  }
}
function Get-UTF8ByteValue {
  Param ( 
    [System.Byte]$Byte
  );
  switch( Get-UTF8ByteType -Byte $Byte ) { 
    0 { $Byte -band 0b000111111 }
    1 { $Byte                   }
    2 { $Byte -band 0b000011111 }
    3 { $Byte -band 0b000001111 }
    4 { $Byte -band 0b000000111 }
  }
}
function Get-UTF8Code {
  Param ( 
    [System.IO.Stream]$Stream
  ); 
  [System.Int16]$Byte1 = $Stream.ReadByte(); 
  if( $Byte1 -eq -1 ) {return -1;}
  [System.Int32]$type  = (Get-UTF8ByteType -Byte $Byte1); 
  [System.Int32]$vv    = (Get-UTF8ByteValue -Byte $Byte1);
  if ( $type -eq 1 ) {
    return $vv; 
  }
  if ( $type -ge 2 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return -1;}
    [System.Int32]$vv_p   = (Get-UTF8ByteValue -Byte $Byte_p);
    $vv *= 0b001000000; 
    $vv += $vv_p;
  } 
  if ( $type -ge 3 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return -1;}
    [System.Int32]$vv_p   = (Get-UTF8ByteValue -Byte $Byte_p);
    $vv *= 0b001000000; 
    $vv += $vv_p;
  }
  if ( $type -ge 4 ) {
    [System.Int16]$Byte_p = $Stream.ReadByte();
    if( $Byte_p -eq -1 ) {return -1;}
    [System.Int32]$vv_p   = (Get-UTF8ByteValue -Byte $Byte_p);
    $vv *= 0b001000000; 
    $vv += $vv_p;
  }
  if ( ($type -ge 5) -or ($type -le 0) ) {
    return -2;
  }
  return $vv;
}
Export-ModuleMember -Function Get-UTF8Code;
