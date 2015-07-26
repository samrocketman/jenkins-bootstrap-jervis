/*
   Copyright 2015 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */
/*
   Create Jobs using the script console
   Script should be prepended with the following properties.
     - String jobName
     - String xmlData
 */

import hudson.model.FreeStyleProject
import hudson.model.Item
import jenkins.model.Jenkins
import jenkins.model.ModifiableTopLevelItemGroup

boolean isPropertiesSet = false

try {
    //just by trying to access properties should throw an exception
    jobName == null
    xmlData == null
    isPropertiesSet = true
} catch(MissingPropertyException e) {
    println 'ERROR Can\'t create job.'
    println 'ERROR Missing properties: jobName, xmlData'
}

List<PluginWrapper> plugins = Jenkins.instance.pluginManager.getPlugins()
//get a list of installed plugins
Set<String> installed_plugins = []
plugins.each {
    installed_plugins << it.getShortName()
}

Set<String> required_plugins = ['groovy', 'job-dsl']

if((required_plugins-installed_plugins).size() == 0) {
    if(isPropertiesSet) {
        Jenkins instance = Jenkins.getInstance()
        ModifiableTopLevelItemGroup itemgroup = instance
        int i = jobName.lastIndexOf('/')
        if(i > 0) {
            String group = jobName.substring(0, i)
            Item item = instance.getItemByFullName(group)
            if (item instanceof ModifiableTopLevelItemGroup) {
                itemgroup = (ModifiableTopLevelItemGroup) item
            }
            jobName = jobName.substring(i + 1)
        }
        Jenkins.checkGoodName(jobName)
        if(itemgroup.getJob(jobName) == null) {
            println "Created job \"${jobName}\"."
            itemgroup.createProjectFromXML(jobName, new ByteArrayInputStream(xmlData.getBytes()))
            instance.save()
        } else {
            println "Job \"${jobName}\" already exists.  Nothing changed."
        }
    }
} else {
    println 'Unable to create job.'
    println "Missing required plugins: ${required_plugins-installed_plugins}"
}
