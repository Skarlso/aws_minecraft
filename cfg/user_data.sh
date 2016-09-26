#!/bin/bash
sudo su
yum update -y
yum install git -y
yum install libevent-devel -y
yum install ncurses-devel -y
yum install glibc-static -y
yum install java-1.8.0-openjdk -y
yum groupinstall "Development tools" -y
cd ~
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xzvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure && make
make install

su ec2-user
cd ~
wget https://github.com/tmux/tmux/releases/download/2.2/tmux-2.2.tar.gz
tar xfvz tmux-2.2.tar.gz
cd tmux-2.2
./configure && make
