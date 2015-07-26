#!/bin/bash
#Created by Sam Gleske (https://github.com/samrocketman) #Copyright 2015 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis
#Wed May 20 23:22:07 EDT 2015
#Ubuntu 14.04.2 LTS
#Linux 3.13.0-52-generic x86_64
#GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
#curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3

#A script which bootstraps a Jenkins installation for executing Jervis Job DSL scripts

source scripts/common.sh

export JENKINS_HOME="${JENKINS_HOME:-my_jenkins_home}"
export jenkins_url="${jenkins_url:-http://mirrors.jenkins-ci.org/war/latest/jenkins.war}"
export CURL="${CURL:-curl}"

#download jenkins, start it up, and update the plugins
if [ ! -e "jenkins.war" ]; then
  ./scripts/provision_jenkins.sh download-file "${jenkins_url}"
fi
if ! ./scripts/provision_jenkins.sh status; then
  ./scripts/provision_jenkins.sh start
fi
#wait for jenkins to become available
./scripts/provision_jenkins.sh url-ready "http://localhost:8080/jnlpJars/jenkins-cli.jar"
#update and install plugins
echo "Bootstrap Jenkins via script console (may take a while without output)"
echo "NOTE: you could open a new terminal and tail -f console.log"
jenkins_console --script "./scripts/bootstrap.groovy"
#conditional restart jenkins
if $(CURL="${CURL} -s" jenkins_console --script "./scripts/console-needs-restart.groovy"); then
  ./scripts/provision_jenkins.sh restart
fi
#wait for jenkins to become available
./scripts/provision_jenkins.sh url-ready "http://localhost:8080/jnlpJars/jenkins-cli.jar"
#create the first job, _jervis_generator.  This will use Job DSL scripts to generate other jobs.
#curl --data-urlencode "script=String itemName='_jervis_generator';String xmlData='''$(<./configs/job_jervis_config.xml)''';$(<./scripts/create-job.groovy)" http://localhost:8080/scriptText
curl_item_script --item-name "_jervis_generator" \
  --xml-data "./configs/job_jervis_config.xml" \
  --script "./scripts/create-job.groovy"
#generate Welcome view
curl --data-urlencode "script=String itemName='Welcome';String xmlData='''$(<./configs/view_welcome_config.xml)''';$(<./scripts/create-view.groovy)" http://localhost:8080/scriptText
#generate GitHub Organizations view
curl --data-urlencode "script=String itemName='GitHub Organizations';xmlData='''$(<configs/view_github_organizations_config.xml)''';$(<./scripts/create-view.groovy)" http://localhost:8080/scriptText
#setting default view to Welcome
jenkins_console --script "./scripts/configure-primary-view.groovy"
#configure docker slaves
#curl -d "script=$(<./scripts/configure-docker-cloud.groovy)" http://localhost:8080/scriptText
echo 'Jenkins is ready.  Visit http://localhost:8080/'
