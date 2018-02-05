#!/bin/bash
source jenkins-bootstrap-shared/jenkins_bootstrap.sh

#create the first job, _jervis_generator.  This will use Job DSL scripts to generate other jobs.
create_job --job-name "_jervis_generator" --xml-data "./configs/job_jervis_config.xml"
#generate Welcome view
create_view --view-name "Welcome" --xml-data "./configs/view_welcome_config.xml"
#generate GitHub Organizations view
create_view --view-name "GitHub Organizations" --xml-data "./configs/view_github_organizations_config.xml"
#setting default view to Welcome
jenkins_console --script "${SCRIPT_LIBRARY_PATH}/configure-primary-view.groovy"
#set markup formatter to HTML
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-markup-formatter.groovy"
#configure jenkins agent credentials
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/credentials-jenkins-agent.groovy"
#disable agent -> master security
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/security-disable-agent-master.groovy"
#disable job dsl script security
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-job-dsl-security.groovy"
#only enable JNLP4 agent protocol
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-jnlp-agent-protocols.groovy"
#configure grapeConfig.xml
if [ -n "${VAGRANT_JENKINS}" -o "${DOCKER_JENKINS}" ]; then
  jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-grape-ivy-xml.groovy"
fi
if [ -r settings.groovy ]; then
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-jenkins-settings.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/credentials-multitype.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-pipeline-global-shared-libraries.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-github-plugin.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-yadocker-cloud.groovy
elif [ -n "${GITHUB_TOKEN}" ]; then
  #configure legacy github credentials if applicable
  jenkins_console --script <(echo "String gh_token='${GITHUB_TOKEN}';") --script ./scripts/credentials-github-token.groovy
fi
