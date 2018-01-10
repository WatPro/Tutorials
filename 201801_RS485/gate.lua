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
    length     = ProtoField.uint32("gate.length", "UDP Length", base.DEC), 
    begin      = ProtoField.uint8("gate.begin", "Begin Of Section", base.HEX, {
        [0x7e] = "Correct Beginning Byte"
    }), 
    serial     = ProtoField.uint16("gate.sn", "Board Serial Number", base.DEC), 
    func       = ProtoField.uint16("gate.function", "Function", base.HEX, {
        [0x1081] = "Get Status"
    }), 
    check      = ProtoField.bool("gate.check", "Checksum", base.NONE, {
        [1] = "Passed", 
        [2] = "Failed"
    }), 
    ends       = ProtoField.uint8("gate.end", "End Of Section", base.HEX, {
        [0x0d] = "Correct Ending Byte"
    }), 
    record     = ProtoField.uint32("gate.length", "Record Index", base.DEC), 
    time       = ProtoField.uint32("gate.time", "Date(Board)", base.DEC),
    day        = ProtoField.uint8("gate.day", "Weekday(Board)", base.DEC, {
        [0] = "Sunday", 
        [1] = "Monday", 
        [2] = "Tuesday", 
        [3] = "Wednesday", 
        [4] = "Thursday",
        [5] = "Friday", 
        [6] = "Saturday"
    }), 
    tot_record = ProtoField.uint32("gate.tot_record", "Total Number of Records", base.DEC), 
    tot_reg    = ProtoField.uint16("gate.registration", "Total Number of Registrations", base.DEC), 
    card       = ProtoField.uint32("gate.card", "Card ID", base.DEC)
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
    tree:add(proto_fields.serial, buffer(1,2), buffer(1,1):uint()+0x100*buffer(2,1):uint())
    cmd   = buffer(3,1):uint()+0x100*buffer(4,1):uint()
    check = buffer(31,1):uint()+0x100*buffer(32,1):uint()
    data  = buffer(1,30) 
    tree:add(proto_fields.check, buffer(31,2), check == Checksum(data), nil, "("..string.format("%X",check)..")") 
    tree:add(proto_fields.ends, buffer(33,1), buffer(33,1):uint()) 
    subtree = tree:add(proto_fields.func, buffer(3,2), cmd) 
    if     cmd == 0x1081 then get_status(buffer, pinfo, subtree) 
    else
    end
end 

function get_status(buffer, pinfo, tree)
    if     pinfo.src_port == default_settings.port and pinfo.dst_port ~= default_settings.port then 
        local year        = readBCD(buffer(5,1):uint())
        local month       = readBCD(buffer(6,1):uint()) 
        local day         = readBCD(buffer(7,1):uint()) 
        local wday_buff   = buffer(8,1)
        local weekday     = readBCD(wday_buff:uint()) 
        local hour        = readBCD(buffer(9,1):uint()) 
        local min         = readBCD(buffer(10,1):uint())
        local sec         = readBCD(buffer(11,1):uint())
        local datetime    = os.time({
            year  = 2000+year, 
            month = month, 
            day   = day, 
            hour  = hour, 
            min   = min, 
            sec   = sec
        })
        local wday_match  = weekday == os.date("*t", datetime).wday-1
        tree:add(proto_fields.time, buffer(5,7), datetime, nil, "("..os.date("%Y-%m-%d %X", datetime)..")")
        tree:add(proto_fields.day, wday_buff, weekday, nil, wday_match and "Matched" or "Not Matched")
        local tot_rc_buff = buffer(12,3)
        local tot_record  = readLH(tot_rc_buff)
        tree:add(proto_fields.tot_record, tot_rc_buff, tot_record)
        local tot_rg_buff = buffer(15,2)
        local tot_reg     = readLH(tot_rg_buff)
        tree:add(proto_fields.tot_reg, tot_rg_buff, tot_reg)
    elseif pinfo.src_port ~= default_settings.port and pinfo.dst_port == default_settings.port then 
        local record_buffer = buffer(5,4)
        local record        = readLH(record_buffer)
        if record == 0x0 or record == 0xffffffff then 
            tree:add(proto_fields.record, record_buffer, record, nil, "(Get The Newest Record)")
        else
            tree:add(proto_fields.record, record_buffer, record)
        end 
    end 
end 

function Checksum(buffer)
    local ll  = buffer:len()
    local sum = 0
    for ii=ll-1,0,-1
    do 
        sum = sum + buffer(ii,1):uint() 
    end 
    return sum
end 

function readLH(buffer)
    local ll     = buffer:len()
    local result = 0
    for ii=ll-1,0,-1
    do 
        result = 0x100*result
        result = result + buffer(ii,1):uint()
    end 
    return result 
end 
 
function readBCD(uint8) 
-- Binary-Coded Decimal
     return math.floor(uint8/0x10)*10 + uint8%0x10
end 
 
local udp_table = DissectorTable.get("udp.port")
udp_table:add(default_settings.port,gate_proto)
 
