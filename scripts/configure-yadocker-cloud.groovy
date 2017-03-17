/*
   Copyright 2015-2017 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis

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
   Configure Yet Another Docker clouds provided by the Yet Another Docker
   Plugin.  This Jenkins Script Console script makes it easy to maintain large
   amounts of configured clouds.

   Note: This script deletes all yet another docker cloud configurations from
   Jenkins before configuring the clouds.  It does not affect in-process
   builds.  However, if there are previously configured yet another docker
   clouds then they will be removed.

   Yet Another Docker Plugin 0.1.0-rc31
 */

//configure cloud stack

import com.github.kostyasha.yad.DockerCloud
import com.github.kostyasha.yad.DockerConnector
import com.github.kostyasha.yad.DockerContainerLifecycle
import com.github.kostyasha.yad.DockerSlaveTemplate
import com.github.kostyasha.yad.commons.DockerCreateContainer
import com.github.kostyasha.yad.commons.DockerImagePullStrategy
import com.github.kostyasha.yad.commons.DockerPullImage
import com.github.kostyasha.yad.commons.DockerRemoveContainer
import com.github.kostyasha.yad.commons.DockerStopContainer
import com.github.kostyasha.yad.launcher.DockerComputerLauncher
import com.github.kostyasha.yad.launcher.DockerComputerSSHLauncher
import com.github.kostyasha.yad.strategy.DockerOnceRetentionStrategy

import hudson.model.Node
import hudson.plugins.sshslaves.SSHConnector
import hudson.slaves.RetentionStrategy
import net.sf.json.JSONArray
import net.sf.json.JSONObject

/*
  TODO: things left to implement
    - connection_type
    - implement jnlp
    - set jnlp to default launch method
    - implement environment variables (node settings)
    - implement tool locations (node settings)

    Contribute upstream remoteFsRootMapping
*/

JSONArray clouds_yadocker = [
    //YET ANOTHER DOCKER CLOUD (this is an item in a list of clouds)
    [
        cloud_name: "docker-local",
        docker_url: "tcp://localhost:2375",
        docker_api_version: "",
        host_credentials_id: "",
        //valid values: netty, jersey
        connection_type: "netty",
        connect_timeout: 0,
        max_containers: 50,
        docker_templates: [
            //DOCKER TEMPLATE (this is an item in a list of templates)
            [
                max_instances: 10,
                //DOCKER CONTAINER LIFECYCLE
                docker_image_name: "",
                //PULL IMAGE SETTINGS
                //valid values: pull_latest, pull_always, pull_once, pull_never
                pull_strategy: "pull_latest",
                pull_registry_credentials_id: "",
                //CREATE CONTAINER SETTINGS
                docker_command: "",
                hostname: "",
                dns: "",
                //this can be a string or list of strings
                volumes: "",
                environment: "",
                port_bindings: "",
                bind_all_declared_ports: false,
                //0 is unlimited
                memory_limit_in_mb: 0,
                cpu_shares: 0,
                run_container_privileged: false,
                allocate_pseudo_tty: false,
                mac_address: "",
                extra_hosts: "",
                network_mode: "",
                devices: "",
                cpuset_constraint_cpus: "",
                cpuset_constraint_mems: "",
                links: "",
                //STOP CONTAINER SETTINGS
                stop_container_timeout: 10,
                //STOP CONTAINER SETTINGS
                remove_volumes: false,
                force_remove_containers: false,
                //JENKINS SLAVE CONFIG
                remote_fs_root: "/home/jenkins",
                labels: "docker",
                //valid values: exclusive or normal
                usage: "exclusive",
                availability_strategy: "docker_once_retention_strategy",
                availability_idle_timeout: 10,
                executors: 1,
                //LAUNCH METHOD
                //valid values: launch_ssh or launch_jnlp
                launch_method: "launch_ssh",
                //settings specific to launch_ssh (you only need one or the other)
                launch_ssh_credentials_id: "",
                launch_ssh_port: 22,
                launch_ssh_java_path: "",
                launch_ssh_jvm_options: "",
                launch_ssh_prefix_start_slave_command: "",
                launch_ssh_suffix_start_slave_command: "",
                launch_ssh_connection_timeout: 120,
                launch_ssh_max_num_retries: 10,
                launch_ssh_time_wait_between_retries: 10,
                //settings specific to launch_jnlp
                launch_jnlp_linux_user: "jenkins",
                launch_jnlp_lauch_timeout: 120,
                launch_jnlp_slave_jar_options: "",
                launch_jnlp_slave_jvm_options: "",
                launch_jnlp_different_jenkins_master_url: "",
                launch_jnlp_ignore_certificate_check: false,
                //NODE PROPERTIES
                environment_variables: [],
                tool_locations: [],
                remote_fs_root_mapping: ""
            ]
        ]

    ]
] as JSONArray

//return a launcher
def selectLauncher(String launcherType, JSONObject obj) {
    switch(launcherType) {
        case 'launch_ssh':
            SSHConnector sshConnector = new SSHConnector(obj.optInt('launch_ssh_port', 22),
                    obj.optString('launch_ssh_credentials_id'),
                    obj.optString('launch_ssh_jvm_options'),
                    obj.optString('launch_ssh_java_path'),
                    obj.optString('launch_ssh_prefix_start_slave_command'),
                    obj.optString('launch_ssh_suffix_start_slave_command'),
                    obj.optInt('launch_ssh_connection_timeout'),
                    obj.optInt('launch_ssh_max_num_retries'),
                    obj.optInt('launch_ssh_time_wait_between_retries')
                    )
            return new DockerComputerSSHLauncher(sshConnector)
        default:
            return null
    }
}

//create a new instance of the DockerCloud class from a JSONObject
def newDockerCloud(JSONObject obj) {
    DockerConnector connector = new DockerConnector(obj.optString('docker_url', 'tcp://localhost:2375'))
    if(obj.optInt('connect_timeout')) {
        connector.setConnectTimeout(obj.optInt('connect_timeout'))
    }
    connector.setApiVersion(obj.optString('docker_api_version'))
    connector.setCredentialsId(obj.optString('host_credentials_id'))
    //connector.setConnectorType() not used maybe implement later al la connection_type

    DockerCloud cloud = new DockerCloud(obj.optString('cloud_name'),
                       bindJSONToList(DockerSlaveTemplate.class, obj.opt('docker_templates')),
                       obj.optInt('max_containers', 50),
                       connector)

    return cloud
}

def newDockerSlaveTemplate(JSONObject obj) {
    //DockerPullImage
    DockerPullImage pullImage = new DockerPullImage()
    String pullStrategy = obj.optString('pull_strategy', 'PULL_LATEST').toUpperCase()
    if(pullStrategy in ['PULL_LATEST', 'PULL_ALWAYS', 'PULL_ONCE', 'PULL_NEVER']) {
        pullImage.setPullStrategy(DockerImagePullStrategy."${pullStrategy}")
    }
    else {
        pullImage.setPullStrategy(DockerImagePullStrategy.PULL_LATEST)
    }
    pullImage.setCredentialsId(obj.optString('pull_registry_credentials_id'))

    //DockerCreateContainer
    DockerCreateContainer createContainer = new DockerCreateContainer()
    createContainer.setBindPorts(obj.optString('port_bindings'))
    createContainer.setBindAllPorts(obj.optBoolean('bind_all_declared_ports', false))
    createContainer.setDnsString(obj.optString('dns'))
    createContainer.setHostname(obj.optString('hostname'))
    if(obj.optLong('memory_limit_in_mb')) {
        createContainer.setMemoryLimit(obj.optLong('memory_limit_in_mb'))
    }
    createContainer.setPrivileged(obj.optBoolean('run_container_privileged', false))
    createContainer.setTty(obj.optBoolean('allocate_pseudo_tty', false))
    if(obj.optJSONArray('volumes')) {
        createContainer.setVolumes(obj.optJSONArray('volumes') as List<String>)
    }
    else {
        createContainer.setVolumesString(obj.optString('volumes'))
    }
    createContainer.setVolumesFromString(obj.optString('volumes_from'))
    createContainer.setMacAddress(obj.optString('mac_address'))
    if(obj.optInt('cpu_shares')) {
        createContainer.setCpuShares(obj.optInt('cpu_shares'))
    }
    createContainer.setCommand(obj.optString('docker_command'))
    createContainer.setEnvironmentString(obj.optString('environment'))
    createContainer.setExtraHostsString(obj.optString('extra_hosts'))
    createContainer.setNetworkMode(obj.optString('network_mode'))
    createContainer.setDevicesString(obj.optString('devices'))
    createContainer.setCpusetCpus(obj.optString('cpuset_constraint_cpus'))
    createContainer.setCpusetMems(obj.optString('cpuset_constraint_mems'))
    createContainer.setLinksString(obj.optString('links'))

    //DockerStopContainer
    DockerStopContainer stopContainer = new DockerStopContainer()
    stopContainer.setTimeout(obj.optInt('stop_container_timeout', 10))

    //DockerRemoveContainer
    DockerRemoveContainer removeContainer = new DockerRemoveContainer()
    removeContainer.setRemoveVolumes(obj.optBoolean('remove_volumes', false))
    removeContainer.setForce(obj.optBoolean('force_remove_containers', false))

    //DockerContainerLifecycle
    DockerContainerLifecycle dockerContainerLifecycle = new DockerContainerLifecycle()
    dockerContainerLifecycle.setImage(obj.optString('docker_image_name'))
    dockerContainerLifecycle.setPullImage(pullImage)
    dockerContainerLifecycle.setCreateContainer(createContainer)
    dockerContainerLifecycle.setStopContainer(stopContainer)
    dockerContainerLifecycle.setRemoveContainer(removeContainer)

    //DockerOnceRetentionStrategy
    //this availability_strategy is for "run_once".  We can customize it later
    RetentionStrategy retentionStrategy = new DockerOnceRetentionStrategy(obj.optInt('availability_idle_timeout', 10))

    //DockerComputerLauncher
    //select a launch method from the list of available launch methods
    List<String> launch_methods = ['launch_ssh', 'launch_jnlp']
    String default_launch_method = 'launch_ssh'
    String user_selected_launch_method = obj.optString('launch_method', default_launch_method).toLowerCase()
    String launch_method = (user_selected_launch_method in launch_methods)? user_selected_launch_method : default_launch_method
    DockerComputerLauncher launcher = selectLauncher(launch_method, obj)

    //DockerSlaveTemplate
    DockerSlaveTemplate dockerSlaveTemplate = new DockerSlaveTemplate()
    dockerSlaveTemplate.setDockerContainerLifecycle(dockerContainerLifecycle)
    dockerSlaveTemplate.setLabelString(obj.optString('labels', 'docker'))
    String node_usage = (obj.optString('usage', 'EXCLUSIVE').toUpperCase().equals('NORMAL'))? 'NORMAL' : 'EXCLUSIVE'
    dockerSlaveTemplate.setMode(Node.Mode."${node_usage}")
    dockerSlaveTemplate.setNumExecutors(obj.optInt('executors', 1))
    dockerSlaveTemplate.setRetentionStrategy(retentionStrategy)
    dockerSlaveTemplate.setLauncher(launcher)
    dockerSlaveTemplate.setRemoteFs(obj.optString('remote_fs_root', '/srv/jenkins'))
    dockerSlaveTemplate.setMaxCapacity(obj.optInt('max_instances', 10))
    //dockerSlaveTemplate.setRemoteFsMapping(obj.optString('remote_fs_root_mapping'))
    dockerSlaveTemplate.remoteFsMapping = obj.optString('remote_fs_root_mapping')

    return dockerSlaveTemplate
}

def bindJSONToList(Class type, Object src) {
    if(!(type == DockerCloud) && !(type == DockerSlaveTemplate)) {
        throw new Exception("Must use DockerCloud or DockerSlaveTemplate class.")
    }
    //docker_array should be a DockerCloud or DockerSlaveTemplate
    ArrayList<?> docker_array
    if(type == DockerCloud){
        docker_array = new ArrayList<DockerCloud>()
    }
    else {
        docker_array = new ArrayList<DockerSlaveTemplate>()
    }
    //cast the configuration object to a Docker instance which Jenkins will use in configuration
    if (src instanceof JSONObject) {
        //uses string interpolation to call a method
        //e.g instead of newDockerCloud(src) we use instead...
        docker_array.add("new${type.getSimpleName()}"(src))
    }
    else if (src instanceof JSONArray) {
        for (Object o : src) {
            if (o instanceof JSONObject) {
                docker_array.add("new${type.getSimpleName()}"(o))
            }
        }
    }
    return docker_array
}

if(!Jenkins.instance.isQuietingDown()) {
    ArrayList<DockerCloud> clouds = new ArrayList<DockerCloud>()
    clouds = bindJSONToList(DockerCloud.class, clouds_yadocker)
    if(clouds.size() > 0) {
        dockerConfigUpdated = true
        Jenkins.instance.clouds.removeAll(DockerCloud)
        Jenkins.instance.clouds.addAll(clouds)
        clouds*.name.each { cloudName ->
            println "Configured docker cloud ${cloudName}"
        }
        Jenkins.instance.save()
    }
    else {
        println 'Nothing changed.  No docker clouds to configure.'
    }
}
else {
    println 'Shutdown mode enabled.  Configure Docker clouds SKIPPED.'
}

null
