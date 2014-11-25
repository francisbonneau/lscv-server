
## LSCV (Linux System Call Visualization) project

## Server module

### Description

This module consist of a [Sysdig](http://www.sysdig.org/) Chisel built to collect OS data (system calls events) and send it to the [client UI](https://github.com/francisbonneau/lscv-client) (via a [redis](http://www.sysdig.org/) pub/sub channel) where it is going to be analyzed and displayed.

**Tested on Ubuntu 13.10 and 14.04*


### Quick install with Vagrant

Also included is a [Varant](https://www.vagrantup.com/) script to build a Ubuntu 13.10 virtual machine with all the dependencies automatically installed. First install Virtualbox and Vagrant on your machine, then start the automated installation with the following commands : 

```
cd lscv-server
vagrant up

```

### Installation

If you want to install it on an existing machine, you can use the packages directly, or do a manual installation by following these instructions : 

```
# Install Sysdig
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

# Install Redis
sudo apt-get install --yes redis-server

# By default Redis only listen on localhost, so if you run the client app on another machine 
# it wont be able to connect to redis. To fix this you can comment the bind parameter 
# in the redis configuration file /etc/redis/redis.conf and restart redis
#
sudo sh -c "cat /etc/redis/redis.conf | sed s/bind\ 127/\\#\ bind\ 127/ > /etc/redis/redis.conf2"
sudo mv /etc/redis/redis.conf /etc/redis/redis.conf.bkp
sudo mv /etc/redis/redis.conf2 /etc/redis/redis.conf
sudo /etc/init.d/redis-server restart

# Install Lua and the required lua libs
sudo apt-get install --yes lua5.2
sudo apt-get install --yes luarocks
sudo luarocks install luasocket
sudo luarocks install lua-cjson

# Copy the init script and files in /etc for a more permanent installation (optionnal)

sudo cp init.d/lscv-server /etc/init.d/
sudo mkdir /etc/lscv-server
sudo cp -r lib/ lscv-chisel.lua /etc/lscv-server

```

### Usage

Once the installation is completed, simply start sysdig with the lscv-chisel like this : 

```
sudo sysdig -c lscv-chisel.lua &

```

Or use the init script to start the daemon : 

```
/etc/init.d/lscv-server start

```

## Building a deb or rpm package

https://github.com/jordansissel/fpm

https://github.com/jordansissel/pleaserun

```
gem install pleaserun
gem install fpm
```



### Documentation

See the [home page of the project](https://francisbonneau.github.io/lscv/) and the [documentation](https://francisbonneau.github.io/lscv-doc/) (in french) for more information about the project.


## Author

Francis Bonneau, autumn 2014

Created for the course GTI792 at l'ÉTS (http://etsmtl.ca/)

