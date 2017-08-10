#!/bin/bash
#Created by Sam Gleske (https://github.com/samrocketman/home)
#Ubuntu 16.04.2 LTS
#Linux 4.4.0-72-generic x86_64
#Python 2.7.12

function json() {
  python -c "import sys,json;print str(json.load(sys.stdin)[\"${1}\"]).lower()"
}

MESSAGE='Jobb success.'
PIPELINE_INPUT=false
count=0
while true; do
  [ "$(jenkins-call-url ${1%/}/api/json | json building)" = 'false' ] && break
  if [ "$count" -eq "0" ]; then
    if ( jenkins-call-url ${1%/}/consoleText | tail | grep 'Input requested' ); then
      PIPELINE_INPUT=true
      break
    fi
  fi
  #every 15 seconds check consoleText
  ((count++, count = count%3)) || true
  sleep 5
done

if ${PIPELINE_INPUT}; then
  RESULT=SUCCESS
  MESSAGE='Pipeline input requested.'
else
  RESULT=$(jenkins-call-url ${1%/}/api/json | json result | tr 'a-z' 'A-Z')
fi

[ "${RESULT}" = 'SUCCESS' ] && \
  say_job_done.sh "${MESSAGE}" || (
    say_job_done.sh 'Jobb failed.'
    jenkins-call-url ${1%/}/consoleText
  )
