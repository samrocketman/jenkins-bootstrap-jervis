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
#configure jenkins agent credentials
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/credentials-jenkins-agent.groovy"
#disable agent -> master security
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/security-disable-agent-master.groovy"
#disable job dsl script security
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-job-dsl-security.groovy"
#only enable JNLP4 agent protocol
jenkins_console -s "${SCRIPT_LIBRARY_PATH}/configure-jnlp-agent-protocols.groovy"
#configure github credentials if applicable
jenkins_console -s ./settings.groovy --script ./scripts/credentials-github-token.groovy

