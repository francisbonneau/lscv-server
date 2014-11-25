#!/bin/bash
#
# LSCV (Linux System Call Visualization) project
# Francis Bonneau, autumn 2014
# Created for the course GTI792 at l'ÉTS (http://etsmtl.ca/)
#
# Script to create a init file using pleaserun 
# https://github.com/jordansissel/pleaserun
#

# gem install pleaserun
pleaserun --platform sysv --version lsb-3.1 --user root --name lscv-server --chdir /etc/lscv-server sysdig -c lscv-chisel.lua