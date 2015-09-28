#!/bin/bash
#Created by Sam Gleske (https://github.com/samrocketman) #Copyright 2015 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis
#Wed May 20 23:22:07 EDT 2015
#Ubuntu 14.04.2 LTS
#Linux 3.13.0-52-generic x86_64
#GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
#curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3

#A script which bootstraps a Jenkins installation for executing Jervis Job DSL scripts

#sane defaults
export CURL="${CURL:-curl}"
export JENKINS_HOME="${JENKINS_HOME:-my_jenkins_home}"
export jenkins_url="${jenkins_url:-http://mirrors.jenkins-ci.org/war/latest/jenkins.war}"
export JENKINS_WAR="${JENKINS_WAR:-jenkins.war}"
export JENKINS_WEB="${JENKINS_WEB:-http://localhost:8080}"
export BOOTSTRAP_HOME="${BOOTSTRAP_HOME:-.}"
export SCRIPT_LIBRARY_PATH="${SCRIPT_LIBRARY_PATH:-${BOOTSTRAP_HOME}/scripts}"

if [ -e "${SCRIPT_LIBRARY_PATH}/common.sh" ]; then
  source "${SCRIPT_LIBRARY_PATH}/common.sh"
else
  echo "ERROR could not find ${SCRIPT_LIBRARY_PATH}/common.sh"
  echo "Perhaps environment variable SCRIPT_LIBRARY_PATH is not set correctly."
  exit 1
fi

#provision jenkins and plugins
echo 'Downloading specific versions of Jenkins and plugins...'
gradle getjenkins getplugins

if [ -d "${BOOTSTRAP_HOME}/plugins" ]; then
  mkdir -p "${JENKINS_HOME}/plugins"
  ( cd "${BOOTSTRAP_HOME}/plugins/"; ls -1d * ) | while read x; do
    if [ ! -e "${JENKINS_HOME}/plugins/${x}" ]; then
      echo "Copying ${x} to JENKINS_HOME"
      cp -r "${BOOTSTRAP_HOME}/plugins/${x}" "${JENKINS_HOME}/plugins/"
      #pin plugin versions
      #https://wiki.jenkins-ci.org/display/JENKINS/Pinned+Plugins
      touch "${JENKINS_HOME}/plugins/${x}.pinned"
    fi
  done
fi

#download jenkins, start it up, and update the plugins
if [ ! -e "${JENKINS_WAR}" ]; then
  "${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" download-file "${jenkins_url}" "${JENKINS_WAR}"
fi
#check for running jenkins or try to start it
if ! "${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" status; then
  "${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" start
fi
#wait for jenkins to become available
"${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" url-ready "${JENKINS_WEB}/jnlpJars/jenkins-cli.jar"
#update and install plugins
if [ "$1" = "update" ]; then
  echo "Bootstrap Jenkins via script console (may take a while without output)"
  echo "NOTE: you could open a new terminal and tail -f console.log"
  jenkins_console --script "${SCRIPT_LIBRARY_PATH}/bootstrap.groovy"
fi
#conditional restart jenkins
if $(CURL="${CURL} -s" jenkins_console --script "${SCRIPT_LIBRARY_PATH}/console-needs-restart.groovy"); then
  "${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" restart
fi
#wait for jenkins to become available
"${SCRIPT_LIBRARY_PATH}/provision_jenkins.sh" url-ready "${JENKINS_WEB}/jnlpJars/jenkins-cli.jar"
#create the first job, _jervis_generator.  This will use Job DSL scripts to generate other jobs.
create_job --job-name "_jervis_generator" --xml-data "./configs/job_jervis_config.xml"
#generate Welcome view
create_view --view-name "Welcome" --xml-data "./configs/view_welcome_config.xml"
#generate GitHub Organizations view
create_view --view-name "GitHub Organizations" --xml-data "./configs/view_github_organizations_config.xml"
#setting default view to Welcome
jenkins_console --script "${SCRIPT_LIBRARY_PATH}/configure-primary-view.groovy"
#configure docker slaves
#curl -d "script=$(<./scripts/configure-docker-cloud.groovy)" http://localhost:8080/scriptText
echo "Jenkins is ready.  Visit ${JENKINS_WEB}/"
