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
set -x

bash -n ./tests/random_port.sh
test -x ./tests/random_port.sh
export RANDOM_PORT="$(./tests/random_port.sh)"
bash -n ./jervis_bootstrap.sh
test -x ./jervis_bootstrap.sh
export JENKINS_START="java -jar jenkins.war --httpPort=${RANDOM_PORT} --httpListenAddress=127.0.0.1"
export JENKINS_WEB="http://127.0.0.1:${RANDOM_PORT}"
export JENKINS_CLI="java -jar ./jenkins-cli.jar -s http://127.0.0.1:${RANDOM_PORT} -noKeyAuth"
./jervis_bootstrap.sh
curl -s "${JENKINS_WEB}/api/json?pretty=true" | python ./tests/api_test.py
curl -X POST "${JENKINS_WEB}/job/_jervis_generator/build?delay=0sec" --data-urlencode json='{"parameter": [{"name":"project", "value":"samrocketman/jervis"}, {"name":"branch", "value":""}]}'
sleep 1
python ./tests/job_test.py "${JENKINS_WEB}/job/_jervis_generator/lastBuild/api/json?pretty=true"
test -e ./my_jenkins_home/jobs/samrocketman/jobs/jervis-master/config.xml
test -e jenkins.pid
./scripts/provision_jenkins.sh stop
test ! -e jenkins.pid
test -e console.log
test -e jenkins.war
test -e my_jenkins_home
test -e plugins
gradle clean
test ! -e console.log
test ! -e jenkins.war
test ! -e my_jenkins_home
test ! -e plugins
