/*
   Copyright 2015-2018 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis

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
   Automatically approve the post-build groovy script defined in the
   _jervis_generator seed job.  This is the same thing as an admin approving
   the script so it will be run.
 */

import jenkins.model.Jenkins
import org.jvnet.hudson.plugins.groovypostbuild.GroovyPostbuildDescriptor

def j = Jenkins.instance
String jervis_postbuild = j.getItem('_jervis_generator').publishers.find { k, v ->
      k in GroovyPostbuildDescriptor
}.getValue().script.script


//approve script in script approval
script_approval = j.getExtensionList('org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval')[0]
String hash = script_approval.hash(jervis_postbuild, 'groovy')
if(hash in script_approval.approvedScriptHashes) {
    println 'Nothing changed.  _jervis_generator postbuild script already approved.'
}
else {
    script_approval.approveScript(hash)
    script_approval.save()
    println '_jervis_generator postbuild script has been approved in script security.'
}
