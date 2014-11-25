--
-- LSCV (Linux System Call Visualization) project
-- Francis Bonneau, autumn 2014
-- Created for the course GTI792 at l'ÉTS (http://etsmtl.ca/)
--
-- Sysdig Chisel to collect data and send it to a redis channel
--

local redis = require 'lib/redis'
local cjson = require "cjson"

-- Chisel description
description = "publish the events summary to a redis channel"
short_description = "redis publish"
category = "LSCV"

-- Chisel argument list
args = { }

-- Variables
redis_host = '127.0.0.1'
redis_port = 6379
redis_push_interval_ns = 100 * 10^6 -- every 100 ms or (0.1) second


redis_conn = nil

function on_init()
    
    chisel.set_interval_ns(redis_push_interval_ns) 

    -- Request the fileds that we need
    fenum = chisel.request_field("evt.num")
    fuser = chisel.request_field("user.name")
    fproc = chisel.request_field("proc.name")
    ftype = chisel.request_field("evt.type")
    flat = chisel.request_field("evt.latency")
    fdir = chisel.request_field("evt.dir")
    fargs = chisel.request_field("evt.args")

    redis_conn = redis.connect(redis_host, redis_port)

    print("­- Connected to redis")

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


    print("­- Data collection running...")

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
        evt_username = evt.field(fuser)
        evt_procname = evt.field(fproc)
        evt_type = evt.field(ftype)

        -- Make sure the value are not nil
        if evt_procname ~= nil and evt_procname ~= nil and evt_type ~= nil then

            event_id = evt_procname .. '.' .. evt_procname .. '.' .. evt_type

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
