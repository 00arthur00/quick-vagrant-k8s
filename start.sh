#!/bin/sh
vagrant box add --name centos7 --provider libvirt ./CentOS-7-x86_64-Vagrant-1902_01.Libvirt.box
vagrant up --provider libvirt