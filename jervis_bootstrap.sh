#!/bin/bash
#Created by Sam Gleske (https://github.com/samrocketman)
#Wed May 20 23:22:07 EDT 2015
#Ubuntu 14.04.2 LTS
#Linux 3.13.0-52-generic x86_64
#GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
#curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3

#A script which bootstraps a Jenkins installation for executing Jervis Job DSL scripts

#grab the latest copy of the provision_jenkins.sh script
curl -sLo provision_jenkins.sh 'https://raw.githubusercontent.com/samrocketman/home/master/bin/provision_jenkins.sh'
chmod 755 provision_jenkins.sh
#download jenkins, start it up, and update the plugins
./provision_jenkins.sh bootstrap
#install Jervis required plugins
./provision_jenkins.sh install-plugins cloudbees-folder job-dsl view-job-filters
#additional plugins
./provision_jenkins.sh install-plugins embeddable-build-status groovy
./provision_jenkins.sh install-plugins dashboard-view rich-text-publisher-plugin console-column-plugin
#restart jenkins
./provision_jenkins.sh restart
#create the first job, _jervis_generator.  This will use Job DSL scripts to generate other jobs.
./provision_jenkins.sh cli create-job _jervis_generator < ./configs/job_jervis_config.xml
echo 'Jenkins is ready.  Visit http://localhost:8080/'
