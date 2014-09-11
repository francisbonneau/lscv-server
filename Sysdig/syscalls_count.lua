
local redis = require 'redis'
local mp = require 'MessagePack'

-- Chisel description
description = "counts how many times the specified system call has been called"
short_description = "syscall count"
category = "PFE"

-- Chisel argument list
args = { }
 

 function on_init()

 	--chisel.set_interval_s(1)
 	chisel.set_interval_ns(10 * 10^6)

    -- -- Request the fileds that we need    
    fuser = chisel.request_field("user.name")
    fproc = chisel.request_field("proc.name")
    ftype = chisel.request_field("evt.type")
    flat = chisel.request_field("evt.latency")
    fdir = chisel.request_field("evt.dir")

    -- -- set the filter
    -- chisel.set_filter("evt.type=" .. syscallname .. " and evt.dir = >")
    return true
end


events_count = {}

-- Event parsing callback
function on_event()

	--if evt.field(ftype) ~= 'switch' and evt.field(flat) > 0 then

	--if evt.field(ftype) == 'open' and evt.field(flat) > 0 then
	if evt.field(flat) > 0 then

		-- event latency is rounded to the microsecond
		bucket_latency = round(evt.field(flat) / 1000) * 1000

		-- event_id = evt.field(fuser) .. '.' 
		-- event_id = event_id .. evt.field(fproc) .. '.' 
		-- event_id = event_id .. evt.field(ftype) .. '.'
		-- event_id = event_id .. bucket_latency

		event_id = "ALL"

		--event_id = evt.field(ftype) .. '.' .. bucket_latency
		
		if events_count[event_id] == nil then
			events_count[event_id] = 0
		end

		events_count[event_id] = events_count[event_id] + 1
    end

    return true
end


function on_interval(ts_s, ts_ns, delta)
	--print(events_count)

	print(' ')
	print(' ')
	print('____________________________________________________')
	print(' ')

	-- Messagepack encoding
	mp.set_number'float'
	mp.set_integer'unsigned'
	mp.set_array'with_hole'
	mp.set_string'string'

	data = mp.pack(events_count)
	
	local client = redis.connect('127.0.0.1', 6379)
	client:set('data' .. ts_s, data)


	for key,value in pairs(events_count) do print(key,value) end
	events_count = {}

	return true
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end