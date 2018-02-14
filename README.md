# Bootstrap Jenkins using Jervis [![Build Status][travis-status]][travis]

[Jervis][jervis] generates Jenkins jobs using Travis CI YAML.  This project is
meant to bootstrap Jenkins from scratch and pre-configure it to use Jervis.

# Instructions

### Clone this project

This project uses a submodule.  Therefore, cloning it must include also cloning
the submodule.

    git clone --recursive https://github.com/samrocketman/jenkins-bootstrap-jervis.git

### GitHub API key

Log into GitHub and [generate an API token][gh-token] so that Jervis can
authenticate to the GitHub API.

### Provision Jenkins

Using Vagrant is the recommended way to provision.  Copy
[`settings.groovy.EXAMPLE`](settings.groovy.EXAMPLE) to `settings.groovy` and
fill in the [GitHub personal access token][gh-token].

    export VAGRANT_JENKINS=1
    vagrant up
    ./jervis_bootstrap.sh

Alternatively, provision without Vagrant.

    #not a real token
    export GITHUB_TOKEN="abca2bf1000cd67f7d805612b43195ce9c10a123"
    ./jervis_bootstrap.sh

Visit `http://localhost:8080/` to see Jenkins running with Jervis.  Simply read
the Welcome page for next steps.


### Screenshot

[Jervis][jervis] built from this Jenkins instance.

![Screenshot of rendered Jervis pipeline][jenkins-jervis-screenshot]

### License

* [Apache License 2.0](LICENSE)
* [3rd party licenses](3rd_party)

[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
[jenkins-auth]: https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin#GithubOAuthPlugin-CallingJenkinsAPIusingGitHubPersonalAccessTokens
[jenkins-cli]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI
[jenkins-console]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console
[jenkins-jervis-screenshot]: https://user-images.githubusercontent.com/875669/36202110-54d63018-1137-11e8-949a-ac2d7682ace7.png
[jenkins-source]: https://github.com/jenkinsci/jenkins
[jervis]: https://github.com/samrocketman/jervis
[travis-status]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis.svg
[travis]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis
