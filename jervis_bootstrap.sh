#!/bin/bash
source jenkins-bootstrap-shared/jenkins_bootstrap.sh

#create the first job, _jervis_generator.  This will use Job DSL scripts to generate other jobs.
create_job --job-name '_jervis_generator' --xml-data './configs/job_jervis_config.xml'
create_job --job-name '__clean_abandoned_branches_multibranch' --xml-data './configs/job_maintenance_clean_abandoned_branches_multibranch_config.xml'
#generate Welcome view
create_view --view-name 'Welcome' --xml-data './configs/view_welcome_config.xml'
#generate GitHub Organizations view
create_view --view-name 'GitHub Organizations' --xml-data "./configs/view_github_organizations_config.xml"
#generate Maintenance view
create_view --view-name 'Maintenance' --xml-data './configs/view_maintenance_config.xml'
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
#global Jenkinsfile
jenkins_console -s ./configs/global-jenkinsfile.groovy -s "${SCRIPT_LIBRARY_PATH}/configure-global-jenkinsfile.groovy"
#restrict master so only _jervis_generator can execute
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-job-restrictions-master.groovy"
#approve admin groovy scripts
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/admin-script-approval.groovy"
#configure grapeConfig.xml
if [ -n "${VAGRANT_JENKINS}" -o "${DOCKER_JENKINS}" ]; then
  jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-grape-ivy-xml.groovy"
fi
if [ ! -r settings.groovy -a -n "${GITHUB_TOKEN}" ]; then
  sed -r "s#(String GITHUB_TOKEN = \")[^\"]+(\".*)#\\1${GITHUB_TOKEN}\\2#" settings.groovy.EXAMPLE > settings.groovy
fi
if [ -r settings.groovy ]; then
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-jenkins-settings.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/credentials-multitype.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-pipeline-global-shared-libraries.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-github-plugin.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-yadocker-cloud.groovy
  jenkins_console -s ./settings.groovy -s "${SCRIPT_LIBRARY_PATH}"/configure-github-oauth.groovy
fi
