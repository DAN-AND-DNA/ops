#!/bin/bash


sudo apt-get install -y ssh
sudo apt install -y lrzsz

sudo apt-get remove vim-common
sudo apt-get install -y vim

sudo sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
sudo apt-get update

sudo apt-get install -y build-essential