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
  if( $Byte -eq -1 ) {return (,$Empty);}
  [System.Int16]$type   = (Get-UTF8ByteType -Byte $Byte);
  if ( ($type -ge 5) -or ($type -le 0) ) {
    return (,$Empty);
  }
  [System.Byte[]]$bytes = @($Byte); 
  for ([System.Int16]$ii=2; $ii -le $type; $ii += 1) {
    [System.Int16]$Byte = $Stream.ReadByte();
    [System.Int16]$tt   = (Get-UTF8ByteType -Byte $Byte);
    if(($Byte -eq -1) -or ($tt -ne 0)) {return (,$Empty);}
    $bytes += $Byte; 
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
function Get-UTF8Bytes() {
  Param (
    [System.Int32]$Unicode
  );
  [System.Byte[]]$Empty = @(); 
  if(($Unicode -lt 0) -or ($Unicode -gt 0x0010FFFF)) {
    return (,$Empty);
  }
  [System.Byte[]]$Bytes = @();
  if($Unicode -lt 0x00000080) {      ## 1-byte
    [System.Int32]$vv = $Unicode -band 0x0000007F; 
    $vv    += 0x00;
    $Bytes += $vv; 
  }else{
    if($Unicode -lt 0x00000800) {    ## 2-byte
      [System.Int32]$vv = $Unicode -band 0x000007C0; 
      $vv    /= 0x00000040; 
      $vv    += 0xC0;
      $Bytes += $vv; 
    }else{
      if($Unicode -lt 0x00010000) {  ## 3-byte
        [System.Int32]$vv = $Unicode -band 0x0000F000; 
        $vv    /= 0x00001000; 
        $vv    += 0xE0
        $Bytes += $vv; 
      }else{                         ## 4-byte
        [System.Int32]$vv = $Unicode -band 0x001C0000; 
        $vv    /= 0x00040000; 
        $vv    += 0xF0;
        $Bytes += $vv;
        [System.Int32]$vv = $Unicode -band 0x0003F000; 
        $vv    /= 0x00001000; 
        $vv    += 0x80;
        $Bytes += $vv;
      }
      [System.Int32]$vv = $Unicode -band 0x00000FC0;
      $vv    /= 0x00000040; 
      $vv    += 0x80;
      $Bytes += $vv; 
    }
    [System.Int32]$vv = $Unicode -band 0x0000003F; 
    $vv      /= 0x00000001;
    $vv      += 0x80;
    $Bytes   += $vv; 
  }
  return (,$Bytes);
}

## Reference:  [UTF-8, a transformation format of ISO 10646](https://tools.ietf.org/html/rfc3629#section-3 "UTF-8 definition")

Export-ModuleMember -Function Get-FileUTF8Bytes, Get-UTF8Code, Get-UTF8Bytes;

