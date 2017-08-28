#!/bin/bash
/etc/init.d/jenkins stop
rm -rf /var/lib/jenkins/*
ln -s /opt/generator-cache /var/lib/jenkins/.gradle
/etc/init.d/jenkins start
