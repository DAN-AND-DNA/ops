#!/bin/bash

sudo apt-get install ssh
sudo /etc/init.d/ssh start

sudo apt-get remove vim-common
sudo apt-get install vim

sudo sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
apt-get update

sudo apt-get install libncurses5-dev libssl-dev build-essential openssl flex bison libelf-dev
