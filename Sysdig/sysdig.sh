

# latency per process per user
# -d means all events are captured then filtered at print (15% cpu)
sysdig -d -p '%evt.dir %user.name_%proc.name_%evt.type_%evt.latency.ns' evt.dir='<' 


# thread execution time per process per user 
# the absence of the -d means that events are selectively captured (1% cpu)
sysdig -p '%user.name_%proc.name_%evt.type %thread.exectime' evt.type=switch


# Redis
sudo apt-get install redis-server

# Redis lua dependencies
sudo apt-get install lua5.2
sudo apt-get install luarocks
luarocks install luasocket

# Message pack
luarocks install lua-messagepack