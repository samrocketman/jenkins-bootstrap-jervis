# Bootstrap Jenkins using Jervis

[Jervis][jervis] generates Jenkins jobs using Travis CI YAML.

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

Visit http://localhost:8080/ to see Jenkins running with Jervis.  Build the
`_jervis_generator` which will interact with the GitHub API to create Jenkins
jobs based on Travis YAML.

### Screenshot

![jenkins_jervis](https://cloud.githubusercontent.com/assets/875669/7763908/13ffa702-0016-11e5-9e6c-067f59371a6d.png)

[jervis]: https://github.com/samrocketman/jervis
[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
