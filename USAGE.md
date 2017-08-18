# Advanced usage

### Switch versions of Jenkins

Versions of Jenkins are pinned in the `dependencies.gradle` file.  To provision
a new version of Jenkins then update the `dependencies.gradle` file and
bootstrap again.

Plugins are also pinned in the `dependencies.gradle` file.

### Jenkins web endpoint

The Jenkins web endpoint can be customized.  Simply set the `JENKINS_WEB`
environment variable.  By default it points to `http://localhost:8080`.

```bash
export JENKINS_WEB="https://jenkins.example.com"
export JENKINS_USER="admin"
export JENKINS_PASSWORD="somepass"
export REMOTE_JENKINS=1
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
