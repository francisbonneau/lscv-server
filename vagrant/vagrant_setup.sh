#!/bin/bash
#
# LSCV (Linux System Call Visualization) project
# Francis Bonneau, autumn 2014
# Created for the course GTI792 at l'ÉTS (http://etsmtl.ca/)
#
# Simple script to setup a Ubuntu machine to test the LSCV server module
#

echo -e "\n -- Upgrading OS packages \n"
sudo apt-get update
sudo apt-get upgrade

echo -e "\n -- Getting tools \n"

# OS tools
sudo apt-get install --yes git
sudo apt-get install --yes vim 
sudo apt-get install --yes htop
sudo apt-get install --yes tree
sudo apt-get install --yes nload

# Build tools
sudo apt-get install --yes build-essential
sudo apt-get install --yes libtool
sudo apt-get install --yes autoconf
sudo apt-get install --yes automake
sudo apt-get install --yes autoconf-archive
sudo apt-get install --yes pkg-config

echo -e "\n -- Getting Sysdig \n"
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

echo -e "\n -- Getting Redis \n"
sudo apt-get install --yes redis-server

# Configure redis to listen on all interfaces
sudo sh -c "cat /etc/redis/redis.conf | sed s/bind\ 127/\\#\ bind\ 127/ > /etc/redis/redis.conf2"
sudo mv /etc/redis/redis.conf /etc/redis/redis.conf.bkp
sudo mv /etc/redis/redis.conf2 /etc/redis/redis.conf
sudo /etc/init.d/redis-server restart

echo -e "\n -- Getting lua5.2 & luarocks \n"
sudo apt-get install --yes lua5.2
sudo apt-get install --yes luarocks
sudo luarocks install luasocket
sudo luarocks install lua-cjson

echo -e "\n -- Moving files to /etc/lscv-server \n"
sudo cp init.d/lscv-server /etc/init.d/
sudo mkdir /etc/lscv-server
sudo cp -r lib/ lscv-chisel.lua /etc/lscv-server

echo -e "\n -- Starting the service \n"
sudo /etc/init.d/lscv-server start

echo -e "\n -- Done ! \n"
