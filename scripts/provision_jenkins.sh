#!/bin/bash
#Created by Sam Gleske (https://github.com/samrocketman)
#Wed May 20 11:09:18 EDT 2015
#Mac OS X 10.9.5
#Darwin 13.4.0 x86_64
#GNU bash, version 3.2.53(1)-release (x86_64-apple-darwin13)
#curl 7.30.0 (x86_64-apple-darwin13.0) libcurl/7.30.0 SecureTransport zlib/1.2.5
#awk version 20070501
#java version "1.7.0_55"
#Java(TM) SE Runtime Environment (build 1.7.0_55-b13)
#Java HotSpot(TM) 64-Bit Server VM (build 24.55-b03, mixed mode)

#DESCRIPTION
#  Provisions a fresh Jenkins on a local laptop, updates the plugins, and runs
#  it.
#    1. Creates a JAVA_HOME.
#    2. Downloads Jenkins.
#    3. Updates the Jenkins plugins to the latest version.

#USAGE
#  Automatically provision and start Jenkins on your laptop.
#    mkdir ~/jenkins_testing
#    cd ~/jenkins_testing
#    provision_jenkins.sh
#  Kill and completely delete your provisioned Jenkins.
#    cd ~/jenkins_testing
#    provision_jenkins.sh purge
#  Update all plugins to the latest version using jenkins-cli
#    cd ~/jenkins_testing
#    provision_jenkins.sh update-plugins
#  Start or restart Jenkins.
#    cd ~/jenkins_testing
#    provision_jenkins.sh start
#    provision_jenkins.sh restart
#  Stop Jenkins.
#    provision_jenkins.sh stop

#
# USER CUSTOMIZED VARIABLES
#

#Latest Release
jenkins_url="${jenkins_url:-http://mirrors.jenkins-ci.org/war/latest/jenkins.war}"
#LTS Jenkins URL
#jenkins_url="${jenkins_url:-http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war}"
JENKINS_HOME="${JENKINS_HOME:-my_jenkins_home}"
JENKINS_CLI="${JENKINS_CLI:-java -jar ./jenkins-cli.jar -s http://localhost:8080/ -noKeyAuth}"

#Get JAVA_HOME for java 1.7 on Mac OS X
#will only run if OS X is detected
if uname -rms | grep Darwin &> /dev/null; then
  JAVA_HOME="$(/usr/libexec/java_home -v 1.7)"
  PATH="${JAVA_HOME}/bin:${PATH}"
  echo "JAVA_HOME=${JAVA_HOME}"
  java -version
fi

export jenkins_url JENKINS_HOME JAVA_HOME PATH JENKINS_CLI

#
# FUNCTIONS
#
function download_file() {
  #see bash man page and search for Parameter Expansion
  url="$1"
  file="${1##*/}"
  echo -n "Waiting for ${url} to become available."
  while [ ! "200" = "$(curl -sLiI -w "%{http_code}\\n" -o /dev/null ${url})" ]; do
    echo -n '.'
    sleep 1
  done
  echo 'ready.'
  if [ ! -e "${file}" ]; then
    curl -SLo "${file}" "${url}"
  fi
}

function start_or_restart_jenkins() {
  #start Jenkins, if it's already running then stop it and start it again
  if [ -e "jenkins.pid" ]; then
    echo -n 'Jenkins might be running so attempting to stop it.'
    kill $(cat jenkins.pid)
    #wait for jenkins to stop
    while ps aux | grep -v 'grep' | grep 'jenkins\.war' | grep "$(cat jenkins.pid)" &> /dev/null; do
      echo -n '.'
      sleep 1
    done
    rm jenkins.pid
    echo 'stopped.'
  fi
  echo 'Starting Jenkins.'
  java -jar jenkins.war >> console.log 2>&1 &
  echo "$!" > jenkins.pid
}

function stop_jenkins() {
  if [ -e "jenkins.pid" ]; then
    echo -n 'Jenkins might be running so attempting to stop it.'
    kill $(cat jenkins.pid)
    #wait for jenkins to stop
    while ps aux | grep -v 'grep' | grep "$(cat jenkins.pid)" &> /dev/null; do
      echo -n '.'
      sleep 1
    done
    rm jenkins.pid
    echo 'stopped.'
  fi
}

function update_jenkins_plugins() {
  #download the jenkins-cli.jar client
  download_file 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  echo 'Updating Jenkins Plugins using jenkins-cli.'
  UPDATE_LIST="$( ${JENKINS_CLI} list-plugins | awk '$0 ~ /\)$/ { print $1 }' )"
  if [ ! -z "${UPDATE_LIST}" ]; then
    ${JENKINS_CLI} install-plugin ${UPDATE_LIST}
  fi
}

function install_jenkins_plugins() {
  #download the jenkins-cli.jar client
  download_file 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  echo 'Install Jenkins Plugins using jenkins-cli.'
  ${JENKINS_CLI} install-plugin $@
}

function jenkins_cli() {
  #download the jenkins-cli.jar client
  download_file 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  echo "Executing: ${JENKINS_CLI} $@"
  ${JENKINS_CLI} $@
}

function force-stop() {
  kill -9 $(cat jenkins.pid)
  rm -f jenkins.pid
}

#
# main execution
#

case "$1" in
  bootstrap)
    shift
    skip_restart='false'
    while [ "$#" -gt '0' ]; do
      case $1 in
        --skip-restart)
          skip_restart='true'
          shift
          ;;
        *)
          echo "Error invalid arument provided to bootstrap command: $1"
          exit 1
          ;;
      esac
    done
    #provision Jenkins by default
    #download jenkins.war
    download_file ${jenkins_url}

    #create a JENKINS_HOME directory
    mkdir -p "${JENKINS_HOME}"
    echo "JENKINS_HOME=${JENKINS_HOME}"

    start_or_restart_jenkins

    #disable automatic submission of usage statistics to Jenkins for privacy
    download_file 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
    curl -d 'script=Jenkins.instance.setNoUsageStatistics(true)' http://localhost:8080/scriptText

    update_jenkins_plugins

    install_jenkins_plugins git github github-oauth

    if ! ${skip_restart}; then
      start_or_restart_jenkins
    fi

    echo 'Jenkins is ready.  Visit http://localhost:8080/'
    ;;
  clean)
    force-stop
    rm -f console.log jenkins.pid
    rm -rf "${JENKINS_HOME}"
    ;;
  cli)
    shift
    jenkins_cli $@
    ;;
  install-plugins)
    shift
    install_jenkins_plugins $@
    ;;
  update-plugins)
    update_jenkins_plugins
    echo 'Jenkins may need to be restarted.'
    ;;
  purge)
    force-stop
    rm -f console.log jenkins-cli.jar jenkins.pid jenkins.war
    rm -rf "${JENKINS_HOME}"
    ;;
  start|restart)
    start_or_restart_jenkins
    ;;
  stop)
    stop_jenkins
    ;;
  *)
    cat <<- "EOF"
SYNOPSIS
  provision_jenkins.sh [command] [additional arguments]

DESCRIPTION
  Additional arguments are only available for commands that support it.
  Otherwise, additional arguments will be ignored.

  Provisions a fresh Jenkins on a local laptop, updates the plugins, and runs
  it.  Creates a JAVA_HOME.  Downloads Jenkins.  Updates the Jenkins plugins to
  the latest version.

COMMANDS
  bootstrap                  The bootstrap behavior is to provision Jenkins.
                             This command creates a JAVA_HOME, downloads
                             Jenkins, and updates the plugins to the latest
                             version.  Additionally, it will install the git,
                             github, and github-oauth plugins.

  cli [args]                 This command takes additional arguments.  All
                             arguments are passed through to jenkins-cli.jar.

  clean                      WARNING: destructive command.  Kills the current
                             instance of Jenkins, deletes JENKINS_HOME, removes
                             the jenkins.pid file, and removes the console.log.
                             Use this when you want start from scratch but don't
                             want to download the latest Jenkins.

  install-plugins [args]     This command takes additional arguments.  The
                             additional arguments are one or more Jenkins plugin
                             IDs.

  purge                      WARNING: destructive command.  Deletes all files
                             related to the provisioned Jenkins including the
                             war file and JENKINS_HOME.  If Jenkins is running
                             it will be sent SIGKILL.

  start or                   start and restart do the same thing.  If Jenkins is
  restart                    not running then it will start it.  If Jenkins is
                             already running then it will stop Jenkins and start
                             it again.

  stop                       Will gracefully shutdown Jenkins and leave the
                             JENKINS_HOME intact.

  update-plugins             Updates all unpinned plugins in Jenkins to their
                             latest versions.

EXAMPLE USAGE
  Automatically provision and start Jenkins on your laptop.
    mkdir ~/jenkins_testing
    cd ~/jenkins_testing
    provision_jenkins.sh bootstrap

  Kill and completely delete your provisioned Jenkins.
    cd ~/jenkins_testing
    provision_jenkins.sh purge

  Update all plugins to the latest version using jenkins-cli
    cd ~/jenkins_testing
    provision_jenkins.sh update-plugins

  Install additional plugins e.g. the slack plugin.
    cd ~/jenkins_testing
    provision_jenkins.sh install-plugins slack

  Start or restart Jenkins.
    cd ~/jenkins_testing
    provision_jenkins.sh start
    provision_jenkins.sh restart

  Stop Jenkins.
    provision_jenkins.sh stop

  See Jenkins CLI help documentation.
    provision_jenkins.sh cli help

  Create a Job using Jenkins CLI.
    provision_jenkins.sh cli create-job my_job < config.xml

EOF
esac

