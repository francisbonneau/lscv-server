#!/bin/bash
#
# Simple script to setup a VM

echo " "
echo " -- Upgrading OS packages"
echo " "
sudo apt-get update
sudo apt-get upgrade

echo " "
echo " -- Getting tools"
echo " "
sudo apt-get install --yes vim 
sudo apt-get install --yes htop
sudo apt-get install --yes tree
sudo apt-get install --yes git
sudo apt-get install --yes nload
sudo apt-get install --yes build-essential libtool autoconf automake autoconf-archive pkg-config

echo " "
echo " -- Getting Sysdig "
echo " "
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash


echo " "
echo " -- Getting Redis"
echo " "
sudo apt-get install --yes redis-server
# configure redis to listen on all interfaces
sudo sh -c "cat /etc/redis/redis.conf | sed s/bind\ 127/\\#\ bind\ 127/ > /etc/redis/redis.conf2"
sudo mv /etc/redis/redis.conf /etc/redis/redis.conf.bkp
sudo mv /etc/redis/redis.conf2 /etc/redis/redis.conf
sudo /etc/init.d/redis-server restart

echo " "
echo " -- Getting lua5.2 & luarocks"
echo " "
sudo apt-get install --yes lua5.2 luarocks
sudo luarocks install luasocket


