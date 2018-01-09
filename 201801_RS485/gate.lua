--------------------------------------------------------------------------------
--
-- GATE
--
--------------------------------------------------------------------------------
local default_settings = 
{
    port = 60000 
}

local gate_proto = Proto("GATE", "Gate Control ")
  
local proto_fields = { 
    length = ProtoField.uint32("gate.length", "UDP Length", base.DEC), 
    begin  = ProtoField.uint8("gate.begin", "Begin Of Section", base.HEX, {
        [0x7e] = "Correct Beginning Byte"
    }), 
    serial = ProtoField.uint16("gate.sn", "Board Serial Number", base.DEC), 
    func   = ProtoField.uint16("gate.function", "Function", base.HEX, {
        [0x1081] = "Get A Record "
    }), 
    check  = ProtoField.bool("gate.check", "Checksum", base.NONE, {
        [1] = "Passed", 
        [2] = "Failed"
    }), 
    ends   = ProtoField.uint8("gate.end", "End Of Section", base.HEX, {
        [0x0d] = "Correct Ending Byte"
    }) 
}
gate_proto.fields = proto_fields

function gate_proto.dissector(buffer, pinfo, tree) 
    local packet_len = buffer:len()
    local subtree
    if buffer(0,1):uint() == 0x7e and packet_len == 34 then 
        pinfo.cols.protocol = "GATE" 
        subtree             = tree:add(gate_proto, buffer(), "Gate Control ")
    else 
        return 0 
    end 
    subtree:add(proto_fields.length, buffer(), packet_len, nil, "bytes")
    general_dissector(buffer, pinfo, subtree) 
end 

function general_dissector(buffer, pinfo, tree) 
    local cmd, check, data
    tree:add(proto_fields.begin, buffer(0,1), buffer(0,1):uint())
    tree:add(proto_fields.serial, buffer(1,2), buffer(1,1):uint()+256*buffer(2,1):uint())
    cmd   = buffer(3,1):uint()+256*buffer(4,1):uint()
    check = buffer(31,1):uint()+256*buffer(32,1):uint()
    data  = buffer(1,30)
    tree:add(proto_fields.func, buffer(3,2), cmd) 
    tree:add(proto_fields.check, buffer(31,2), check == Checksum(data), nil, "("..string.format("%X",check)..")") 
    tree:add(proto_fields.ends, buffer(33,1), buffer(33,1):uint())
end 

function Checksum(buffer)
    local length = buffer:len()
    local sum    = 0
    for ii=0,length-1,1
    do 
          sum = sum + buffer(ii,1):uint() 
    end 
    return sum
end 
 
local udp_table = DissectorTable.get("udp.port")
udp_table:add(default_settings.port,gate_proto)
 
