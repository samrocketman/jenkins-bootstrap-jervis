#!/bin/bash -e
export LC_ALL=C
export PS4='$ '
export DEBIAN_FRONTEND=noninteractive
if [ ! -d ".git" ]; then
  echo 'ERROR: must be run from the root of the repository.  e.g.'
  echo './tests/test.sh'
  exit 1
fi
if [ -z "${GITHUB_TOKEN}" ]; then
  echo 'WARNING: Tests may fail without GITHUB_TOKEN environment variable set.'
fi
echo 'Last command to exit has the non-zero exit status.'

#configure error exit trap
function when_done() {
  [ -n "${JENKINS_HEADERS_FILE}" -a -f "${JENKINS_HEADERS_FILE}" ] && rm -f "${JENKINS_HEADERS_FILE}"
  if [ ! "$1" = '0' ]; then
    set +x
    echo "^^ command above has non-zero exit code."
    echo
    echo "Cleaning up test environment: ./gradlew clean"
    ./gradlew clean &> /dev/null
  fi
}
trap 'when_done $?' EXIT

source env.sh
unset JENKINS_START

set -x

bash -n ./tests/random_port.sh
test -x ./tests/random_port.sh
export RANDOM_PORT="$(./tests/random_port.sh)"
bash -n ./jervis_bootstrap.sh
test -x ./jervis_bootstrap.sh
export JENKINS_START="java -jar jenkins.war --httpPort=${RANDOM_PORT} --httpListenAddress=127.0.0.1"
export JENKINS_WEB="http://127.0.0.1:${RANDOM_PORT}"
export JENKINS_CLI="java -jar ./jenkins-cli.jar -s http://127.0.0.1:${RANDOM_PORT} -noKeyAuth"
export JENKINS_HOME="$(mktemp -d ../my_jenkins_homeXXX)"
./jervis_bootstrap.sh

set +x
source "${SCRIPT_LIBRARY_PATH}"/common.sh
export JENKINS_HEADERS_FILE=$(mktemp)
JENKINS_USER=admin JENKINS_PASSWORD="$(<"${JENKINS_HOME}"/secrets/initialAdminPassword)" "${SCRIPT_LIBRARY_PATH}"/jenkins-call-url -a -m HEAD -o /dev/null ${JENKINS_WEB}
set -x

"${SCRIPT_LIBRARY_PATH}"/jenkins-call-url "${JENKINS_WEB}/api/json?pretty=true" | python ./tests/api_test.py
"${SCRIPT_LIBRARY_PATH}"/jenkins-call-url -m POST "${JENKINS_WEB}/job/_jervis_generator/build?delay=0sec" --data-string json= -d <(echo '{"parameter": [{"name":"project", "value":"samrocketman/jervis"}]}')
#sleep 1
timeout 600 "${SCRIPT_LIBRARY_PATH}"/jenkins_wait_job.sh "${JENKINS_WEB}/job/_jervis_generator/lastBuild"
#python ./tests/job_test.py "${JENKINS_WEB}/job/_jervis_generator/lastBuild/api/json?pretty=true"
test -e "$JENKINS_HOME"/jobs/samrocketman/jobs/jervis/config.xml
test -e jenkins.pid
"${SCRIPT_LIBRARY_PATH}"/provision_jenkins.sh stop
test ! -e jenkins.pid
test -e console.log
test -e jenkins.war
test -e "$JENKINS_HOME"
test -e plugins
./gradlew clean
test ! -e console.log
test ! -e jenkins.war
test ! -e "$JENKINS_HOME"
test ! -e plugins
