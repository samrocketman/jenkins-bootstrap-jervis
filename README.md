# Bootstrap Jenkins using Jervis

[Jervis][jervis] generates Jenkins jobs using Travis CI YAML.  This project is
meant to bootstrap Jenkins from scratch and pre-configure it to use Jervis.

* [![Build Status][travis-status]][travis]

# Instructions

### GitHub API key

Log into GitHub and [generate an API token][gh-token] so that Jervis can
authenticate to the GitHub API.

### Provision Jenkins

To provision Jenkins and create the seed job simply run the following command.
Don't forget to export your GitHub API token to the `GITHUB_TOKEN` environment
variable.

    #not a real token
    export GITHUB_TOKEN="abca2bf1000cd67f7d805612b43195ce9c10a123"
    ./jervis_bootstrap.sh

Visit `http://localhost:8080/` to see Jenkins running with Jervis.  Simply read
the Welcome page for next steps.

### Screenshot

![Screenshot of bootstrapped Jenkins with Jervis][jenkins-jervis-screenshot]

# Advanced usage

### Switch versions of Jenkins

Versions of Jenkins are pinned in the `build.gradle` file.  To provision a new
version of Jenkins then update the `build.gradle` file and bootstrap again.

Plugins are also pinned in the `build.gradle` file.

### Jenkins web endpoint

The Jenkins web endpoint can be customized.  Simply set the `JENKINS_WEB`
environment variable.  By default it points to `http://localhost:8080`.

```bash
export JENKINS_WEB="https://jenkins.example.com"
./jervis_bootstrap.sh
```

### Customize JENKINS\_HOME

The `JENKINS_HOME` directory can be overriden to be a custom path.  By default,
`JENKINS_HOME` is set to `my_jenkins_home` based on the current working
directory.

```bash
export JENKINS_HOME="/tmp/my_jenkins_home"
./jervis_bootstrap.sh
```

### Authenticate against Jenkins

If you need to [authenticate to the Jenkins API][jenkins-auth] then you can
override the curl command being used to interact with the Jenkins Script
Console.  Override it via the `CURL` environment variable.

```bash
export CURL="curl --user samrocketman:myGitHubPersonalAccessToken"
./jervis_bootstrap.sh
```

### Jenkins Script Console Library

This project is doing something unique not done by other Jenkins related
projects.  It is building a script library similar to [Jenkins CLI][jenkins-cli]
for the [Jenkins Script Console][jenkins-console].  Except it's a lot faster
because it uses `curl` instead of Java.  Accessing the Jenkins Script Console is
more powerful because then Script Console scripts can be written to be
idempotent.

See the [`scripts/`](scripts) directory for all of the script console scripts.
They are the `*.groovy` scripts.

To write your own script console scripts I look to Jenkins CLI as a reference.
Download the [Jenkins source code][jenkins-source] and search through it for
functions related to Jenkins CLI.  For example, if I want to learn more about
how Jenkins CLI creates jobs then I would simply do the following.

    grep -irl create * | grep cli

This searches for the case-insensitive word `create` and then only shows you
files which contain lower-case `cli` in the path.

[`common.sh`](scripts/common.sh) provides helpful wrappers for executing script
console scripts.  The `SCRIPT_LIBRARY_PATH` can be overridden so that functions
from `common.sh` can be used in any working directory.

```bash
export CURL="curl --user samrocketman:myGitHubPersonalAccessToken"
export JENKINS_WEB="https://jenkins.example.com"
export SCRIPT_LIBRARY_PATH="/path/to/scripts"
source "${SCRIPT_LIBRARY_PATH}/common.sh"
jenkins_console --script "path/to/script.groovy"
```

[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
[jenkins-auth]: https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin#GithubOAuthPlugin-CallingJenkinsAPIusingGitHubPersonalAccessTokens
[jenkins-cli]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI
[jenkins-console]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console
[jenkins-jervis-screenshot]: https://cloud.githubusercontent.com/assets/875669/7763908/13ffa702-0016-11e5-9e6c-067f59371a6d.png
[jenkins-source]: https://github.com/jenkinsci/jenkins
[jervis]: https://github.com/samrocketman/jervis
[travis-status]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis.svg
[travis]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis
