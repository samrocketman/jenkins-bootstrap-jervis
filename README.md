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

To provision Jenkins and create the seed job simply run the following command.
Don't forget to export your GitHub API token to the `GITHUB_TOKEN` environment
variable.

    #not a real token
    export GITHUB_TOKEN="abca2bf1000cd67f7d805612b43195ce9c10a123"
    ./jervis_bootstrap.sh

Visit `http://localhost:8080/` to see Jenkins running with Jervis.  Simply read
the Welcome page for next steps.

Alternatively, use Vagrant to provision.

    export GITHUB_TOKEN="abca2bf1000cd67f7d805612b43195ce9c10a123"
    export VAGRANT_JENKINS=1
    vagrant up
    ./jervis_bootstrap.sh

### Screenshot

![Screenshot of bootstrapped Jenkins with Jervis][jenkins-jervis-screenshot]

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
