
local redis = require 'lib/redis'
-- JSON = (loadfile "lib/json.lua")() 

local cjson = require "cjson"

-- Chisel description
description = "publish the events summary to a redis channel"
short_description = "redis publish"
category = "PFE"

-- Chisel argument list
args = { }

redis_conn = nil

function on_init()

    -- chisel.set_interval_s(1)
    chisel.set_interval_ns(100 * 10^6)

    -- Request the fileds that we need
    fenum = chisel.request_field("evt.num")
    fuser = chisel.request_field("user.name")
    fproc = chisel.request_field("proc.name")
    ftype = chisel.request_field("evt.type")
    flat = chisel.request_field("evt.latency")
    fdir = chisel.request_field("evt.dir")
    fargs = chisel.request_field("evt.args")

    redis_conn = redis.connect('127.0.0.1', 6379)

    -- set the filter
    -- chisel.set_filter("evt.type=" .. syscallname .. " and evt.dir = >")
    return true
    
end


data = {}
events_data = {}

-- Event parsing callback
function on_event()

    --if evt.field(ftype) ~= 'switch' and evt.field(flat) > 0 then
    --if evt.field(ftype) == 'open' and evt.field(flat) > 0 then

    -- capture only events with a latency more than 0 (not switch events)
    -- and exit events only
    --if evt.field(flat) > 0 and evt.field(fproc) ~= 'redis-server' then
    if evt.field(flat) > 0 then
            
        -- generate the event id ( user.process.syscall )
        event_id = evt.field(fuser) .. '.' .. evt.field(fproc) .. '.' .. evt.field(ftype)

        -- put the event latency in the hash containing all events for that id
        if data[event_id] == nil then
            data[event_id] = ''
        end

        data[event_id] = data[event_id] .. evt.field(flat) .. '\t' .. evt.field(fargs) .. '\n'

    end

    return true
end


function on_interval(ts_s, ts_ns, delta)

    -- for key,value in pairs(data) do print(key,value) end
    
    redis_conn:publish('data', cjson.encode(data) )

    data = {}    

    return true
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end