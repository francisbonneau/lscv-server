
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
    chisel.set_interval_ns(100 * 10^6) -- every 100 ms or (0.1) second

    -- Request the fileds that we need
    fenum = chisel.request_field("evt.num")
    fuser = chisel.request_field("user.name")
    fproc = chisel.request_field("proc.name")
    ftype = chisel.request_field("evt.type")
    flat = chisel.request_field("evt.latency")
    fdir = chisel.request_field("evt.dir")
    fargs = chisel.request_field("evt.args")

    redis_conn = redis.connect('127.0.0.1', 6379)


    -- Save information about the machine in redis
    local hostname = backticks_string("hostname")
    redis_conn:set('hostname', hostname)

    local uptime = backticks_string("uptime")
    redis_conn:set('uptime', uptime)

    local cpu_info = backticks_string("cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -c 14-")
    redis_conn:set('cpu_info', cpu_info)
    
    local cpu_count = backticks_string("grep -c processor /proc/cpuinfo")
    redis_conn:set('cpu_count', cpu_count)

    local memory = backticks_string("cat /proc/meminfo | head -n1 | cut -c 18-")
    redis_conn:set('memory', memory)

    return true
    
end


enter_evts_args = {}
data = {}

-- Event parsing callback
function on_event()

    --if evt.field(ftype) ~= 'switch' and evt.field(flat) > 0 then
    --if evt.field(ftype) == 'open' and evt.field(flat) > 0 then

    -- capture only enter events with a latency 
    -- store args in a temporary hash
    if evt.field(ftype) ~= 'switch' and evt.field(flat) == 0 then        
        enter_evts_args[evt.field(fenum)] = evt.field(fargs)
    end

    -- capture only events with a latency more than 0 (not switch events)
    -- and exit events only    
    if evt.field(flat) > 0 then
            
        -- generate the event id ( user.process.syscall )
        event_id = evt.field(fuser) .. '.' .. evt.field(fproc) .. '.' .. evt.field(ftype)

        -- put the event latency in the hash containing all events for that id
        if data[event_id] == nil then
            data[event_id] = ''
        end

        -- find the enter args for that event and combine them to the exit args
        local enter_args = enter_evts_args[evt.field(fenum) - 1 ]
        if (enter_args == nil) then
            enter_args = ''
        end
        local exit_args = evt.field(fargs)

        data[event_id] = data[event_id] .. evt.field(flat) .. '\t' .. enter_args .. '\t'.. exit_args .. '\n'

    end

    return true
end


function on_interval(ts_s, ts_ns, delta)
    
    redis_conn:publish('data', cjson.encode(data) )

    data = {}    
    enter_evts_args = {}

    -- check if there is a filter to apply
    if pcall(apply_filter) then       
        -- sucess
    else
        -- error
    end
        

    return true
end


-- Function to fetch a new filter applied in redis
function apply_filter()
   local filter = redis_conn:get('filter')   
   chisel.set_filter(filter)
end

-- Function to execute OS command and get the output as string
function backticks_string(cmd)
    local string
    local pipe = assert(io.popen(cmd),
        "backticks_string(" .. cmd .. ") failed.")
    local line = pipe:read("*all")
    return line
end