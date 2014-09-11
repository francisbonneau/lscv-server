
local redis = require 'lib/redis'
JSON = (loadfile "lib/json.lua")() 

-- Chisel description
description = "publish the events summary to a redis channel"
short_description = "redis publish"
category = "PFE"

-- Chisel argument list
args = { }
 

 function on_init()

    -- chisel.set_interval_s(1)
    chisel.set_interval_ns(100 * 10^6)

    -- Request the fileds that we need    
    fuser = chisel.request_field("user.name")
    fproc = chisel.request_field("proc.name")
    ftype = chisel.request_field("evt.type")
    flat = chisel.request_field("evt.latency")
    fdir = chisel.request_field("evt.dir")

    -- set the filter
    -- chisel.set_filter("evt.type=" .. syscallname .. " and evt.dir = >")
    return true
end


events = {}

-- Event parsing callback
function on_event()

    --if evt.field(ftype) ~= 'switch' and evt.field(flat) > 0 then
    --if evt.field(ftype) == 'open' and evt.field(flat) > 0 then

    if evt.field(flat) > 0 then
        
        event_content = {}

        event_id = evt.field(fuser) .. '.' 
        event_id = event_id .. evt.field(fproc) .. '.' 
        event_id = event_id .. evt.field(ftype)

        if events[event_id] == nil then
            events[event_id] = ''
        end
        events[event_id] = events[event_id] .. evt.field(flat) .. ','

    end

    return true
end


function on_interval(ts_s, ts_ns, delta)

    for key,value in pairs(events) do print(key,value) end
    
    local data = JSON:encode(events) 

    local client = redis.connect('127.0.0.1', 6379)
    client:publish('data', data)

    events = {}

    return true
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end