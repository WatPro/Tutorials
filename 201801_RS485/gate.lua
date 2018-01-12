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
    length       = ProtoField.uint32("gate.length", "UDP Length", base.DEC), 
    begin        = ProtoField.uint8("gate.begin", "Begin Of Section", base.HEX, {
        [0x7e] = "Correct Beginning Byte"
    }), 
    serial       = ProtoField.uint16("gate.sn", "Board Serial Number", base.DEC), 
    func         = ProtoField.uint16("gate.function", "Function", base.HEX, {
        [0x1081] = "Get Status"
    }), 
    check        = ProtoField.bool("gate.check", "Checksum", base.NONE, {
        [1] = "Passed", 
        [2] = "Failed"
    }), 
    ends             = ProtoField.uint8("gate.end", "End Of Section", base.HEX, {
        [0x0d]       = "Correct Ending Byte"
    }), 
    record_index     = ProtoField.uint32("gate.record_index", "Record Index", base.DEC), 
    time             = ProtoField.uint32("gate.time", "Date(Board)", base.DEC),
    day              = ProtoField.uint8("gate.day", "Weekday(Board)", base.DEC, {
        [0] = "Sunday", 
        [1] = "Monday", 
        [2] = "Tuesday", 
        [3] = "Wednesday", 
        [4] = "Thursday",
        [5] = "Friday", 
        [6] = "Saturday"
    }), 
    tot_record       = ProtoField.uint32("gate.tot_record", "Total Number of Records", base.DEC), 
    tot_regist       = ProtoField.uint16("gate.registration", "Total Number of Registrations", base.DEC), 
    record_card      = ProtoField.uint32("gate.record.card", "Card ID", base.DEC),
    record_datetime  = ProtoField.uint32("gate.record.datetime", "Record Time", base.DEC), 
    record_weekday   = ProtoField.uint8("gate.record.weekday", "Record Weekday", base.DEC)
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
    local data
    local begin_buffer  = buffer(0,1)
    local ends_buffer   = buffer(33,1)
    local serial_buffer = buffer(1,2)
    local serial        = readLH(serial_buffer )
    local cmd_buffer    = buffer(3,2)
    local cmd           = readLH(cmd_buffer) 
    tree:add(proto_fields.begin, begin_buffer, begin_buffer:uint())
    tree:add(proto_fields.serial, serial_buffer, serial)
    local check = readLH(buffer(31,2)) 
    data  = buffer(1,30) 
    tree:add(proto_fields.check, buffer(31,2), check == checksum(data), nil, "("..string.format("%X",check)..")") 
    tree:add(proto_fields.ends, ends_buffer, ends_buffer:uint()) 
    subtree = tree:add(proto_fields.func, buffer(3,2), cmd) 
    if     cmd == 0x1081 then get_status(buffer, pinfo, subtree) 
    else
    end
end 

function get_status(buffer, pinfo, tree)
    if     pinfo.src_port == default_settings.port and pinfo.dst_port ~= default_settings.port then 
        local datetime_buffer  = buffer(5,7)
        local datetime, weekday, wday_buffer, wday_match 
                               = get_datetime_BCD(datetime_buffer) 
        local tot_record_buff  = buffer(12,3)
        local tot_record       = readLH(tot_record_buff)
        local tot_regist_buff  = buffer(15,2)
        local tot_regist       = readLH(tot_regist_buff)
        local record_buffer    = buffer(17,9)
        local record_card, record_date, record_time
        tree:add(proto_fields.time, datetime_buffer, datetime, nil, "("..os.date("%Y-%m-%d %X", datetime)..")")
        tree:add(proto_fields.day, wday_buffer, weekday, nil, wday_match and "Matched" or "Not Matched")
        tree:add(proto_fields.tot_record, tot_record_buff, tot_record)
        tree:add(proto_fields.tot_regist, tot_regist_buff, tot_regist)
        record_info(record_buffer, pinfo, tree) 
    elseif pinfo.src_port ~= default_settings.port and pinfo.dst_port == default_settings.port then 
        local record_buffer = buffer(5,4)
        local record_index  = readLH(record_buffer)
        if record == 0x0 or record == 0xffffffff then 
            tree:add(proto_fields.record_index, record_buffer, record_index, nil, "(Get The Newest Record)")
        else
            tree:add(proto_fields.record_index, record_buffer, record_index)
        end 
    end 
end 

function checksum(buffer)
    local ll  = buffer:len()
    local sum = 0
    for ii=ll-1,0,-1
    do 
        sum = sum + buffer(ii,1):uint() 
    end 
    return sum
end 

function get_datetime_BCD(buffer) 
    local year         = readBCD(buffer(0,1):uint())
    local month        = readBCD(buffer(1,1):uint()) 
    local day          = readBCD(buffer(2,1):uint()) 
    local wday_buffer  = buffer(3,1)
    local weekday      = readBCD(wday_buffer:uint()) 
    local hour         = readBCD(buffer(4,1):uint()) 
    local min          = readBCD(buffer(5,1):uint())
    local sec          = readBCD(buffer(6,1):uint())
    local datetime     = os.time({
        year  = 2000+year, 
        month = month, 
        day   = day, 
        hour  = hour, 
        min   = min, 
        sec   = sec
    })
    local wday_match   = weekday == os.date("*t", datetime).wday-1
    return datetime, weekday, wday_buffer, wday_match
end 

function get_datetime_short(buffer) 
    local year = buffer(0,1):uint() 
    return year
end 

function record_info(buffer, pinfo, tree) 
    local card_buffer = buffer(0,4) 
    local card        = readLH(card_buffer)
    local subtree     = tree:add(proto_fields.record_card, card_buffer, card)
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
 
