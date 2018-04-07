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

Visit `http://localhost:8080/` to see Jenkins running with Jervis.  Simply read
the Welcome page for next steps.  The first example will guide you through
onboarding the [Jervis project][jervis] for CI.

### Screenshot

[Jervis][jervis] built from [the `master` branch][yml-master] by this Jenkins
instance.

![Screenshot Jervis matrix pipeline][jenkins-jervis-screenshot]

[Jervis][jervis] built from [the `jervis_simple` branch][yml-jervis_simple] by
this Jenkins instance.

![Screenshot Jervis simple pipeline][jenkins-jervis-screenshot2]

### Webhook relay

If you wish to try out this project with webhook integration then I recommend
taking advantage of the [webhookrelay service][webhookrelay].

Provision Jenkins in vagrant and then provision a relay automatically.  Pro-tip:
start the relay in a `screen` session so it's easy to detach.

    vagrant ssh
    curl -sSL https://storage.googleapis.com/webhookrelay/downloads/relay-linux-amd64 > relay && chmod +x relay && sudo mv relay /usr/local/bin
    relay forward -b jervis -t internal http://localhost:8080/github-webhook/

Username (token Access Key) and password (token Secret Key) comes from
[webhookrelay tokens][webhookrelay-tokens].

Update the `settings.groovy` file by setting the `github_plugin` > `hookUrl`
setting to the value of the webhookrelay "input".

> Example webhookrelay "input" URL:
> `https://my.webhookrelay.com/v1/webhooks/<uuid>`

Configure Jenkins normally and GitHub repository hooks will now be configured
with a proper webhook when jobs are generated.

### License

* [Apache License 2.0](LICENSE)
* [3rd party licenses](3rd_party)

[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
[jenkins-auth]: https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin#GithubOAuthPlugin-CallingJenkinsAPIusingGitHubPersonalAccessTokens
[jenkins-cli]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI
[jenkins-console]: https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Script+Console
[jenkins-jervis-screenshot2]: https://user-images.githubusercontent.com/875669/36203662-267a2372-113d-11e8-8568-4b79ebf36ff9.png
[jenkins-jervis-screenshot]: https://user-images.githubusercontent.com/875669/36202110-54d63018-1137-11e8-949a-ac2d7682ace7.png
[jenkins-source]: https://github.com/jenkinsci/jenkins
[jervis]: https://github.com/samrocketman/jervis
[travis-status]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis.svg
[travis]: https://travis-ci.org/samrocketman/jenkins-bootstrap-jervis
[webhookrelay-tokens]: https://my.webhookrelay.com/tokens
[webhookrelay]: https://webhookrelay.com/
[yml-jervis_simple]: https://github.com/samrocketman/jervis/blob/jervis_simple/.travis.yml
[yml-master]: https://github.com/samrocketman/jervis/blob/master/.travis.yml
