# Bootstrap Jenkins using Jervis [![Build Status][travis-status]][travis]

[Jervis][jervis] generates Jenkins jobs using Travis CI YAML.  This project is
meant to bootstrap Jenkins from scratch and pre-configure it to use Jervis.

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

### Build an RPM package

    ./gradlew clean buildRpm

### License

* [Apache License 2.0](LICENSE)
* [3rd party licenses](3rd_party)

[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
[jenkins-auth]: https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin#GithubOAuthPlugin-CallingJenkinsAPIusingGitHubPersonalAccessTokens
[jenkins-cli]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI
[jenkins-console]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console
[jenkins-jervis-screenshot]: https://user-images.githubusercontent.com/875669/29012311-72ee817e-7aef-11e7-8823-099f2a45e7ba.png
[jenkins-source]: https://github.com/jenkinsci/jenkins
[jervis]: https://github.com/samrocketman/jervis
[travis-status]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis.svg
[travis]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis
