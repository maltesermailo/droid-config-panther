#!/bin/sh

sleep 60
/usr/libexec/droid-hybris/system/bin/linkerconfig > /linkerconfig.txt
#/usr/libexec/droid-hybris/system/bin/linkerconfig --target /linkerconfig
ls /linkerconfig > /linkerconfig-ls.txt
cat /linkerconfig/ld.config.txt > /linkerconfig-cat.txt
ls /linkerconfig/default > /linkerconfig-ls-default.txt
ls /apex > /apex.txt
