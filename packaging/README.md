# Distribution Packages

Parts or all scripts were taken from https://github.com/jenkinsci/packaging

This provides OS-dependent packages which include the exact versions of Jenkins
and exact versions of plugins.  This provides more repeatable means of upgrading
Jenkins within an immutable infrastructure environment.

### Packaging RPM

To create an RPM package.

    ./gradlew clean buildRpm

To inspect the package.

    rpm -qip --dump --scripts build/distributions/*.rpm | less

### Packaging DEB

> WARNING: DEB packaging is unfinished so not recommended for use

    ./gradlew clean buildDeb

### Build all

Build all available package formats.

    ./gradlew clean packages
