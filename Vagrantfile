# -*- mode: ruby -*-
# vi: set ft=ruby :

# Execute shell script before running vagrant.  This script will run on every
# vagrant command.
system('./scripts/vagrant-up.sh')

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/7"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -e

    # install EPEL repo
    rpm -qa | grep -- epel-release || (
      yum makecache fast
      yum install -y epel-release
    )


    # install IUS repo
    rpm -qa | grep ius-release || (
      [ -r /tmp/ius.asc ] || curl -fLo /tmp/ius.asc https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY
      echo '688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e  /tmp/ius.asc' | sha256sum -c
      rpm --import /tmp/ius.asc
      [ -r /tmp/ius.rpm ] || curl -fLo /tmp/ius.rpm https://centos7.iuscommunity.org/ius-release.rpm
      rpm -K /tmp/ius.rpm
      yum localinstall -y /tmp/ius.rpm
    )


    # install Docker repo
    [ -f /etc/yum.repos.d/docker-ce.repo ] || yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo


    # install packages
    rpm -qa | grep -- docker-ce || (
      yum makecache
      yum install -y yum-utils device-mapper-persistent-data lvm2 git2u docker-ce
      yum install -y vim bind-utils net-tools nc ntpdate
      systemctl start ntpdate
      systemctl enable ntpdate
    )
    [ -f /etc/docker/daemon.json ] || (
      mkdir -p /etc/docker
      cp /vagrant/configs/dockerd-daemon.json /etc/docker/daemon.json
      chmod 700 /etc/docker
      chown root. /etc/docker/daemon.json
      chmod 644 /etc/docker/daemon.json
      systemctl enable docker
      systemctl start docker
    )


    # install Java from Oracle
    JDK_URL='http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.rpm'
    JDK_SHA256='2c1137859aecc0a6aef8960d11967797466e9b812f8c170a43a2597e97dc8a08'
    rpm -qa | grep -- 'jdk1.8' || (
      [ -r /tmp/jdk8.rpm ] || curl -H 'Cookie: oraclelicense=accept-securebackup-cookie' -Lo /tmp/jdk8.rpm "${JDK_URL}"
      echo "${JDK_SHA256}  /tmp/jdk8.rpm" | sha256sum -c -
      yum localinstall -y /tmp/jdk8.rpm
    )


    # build docker image for jenkins slave
    [ -d /opt/jenkins-cache -a -d /opt/gradle-cache -a -d /opt/generator-cache ] || (
      mkdir -p /opt/jenkins-cache /opt/gradle-cache /opt/generator-cache
      chown 1000:1000 /opt/jenkins-cache /opt/gradle-cache
      ln -s /opt/generator-cache /var/lib/jenkins/.gradle
      cp -f /vagrant/scripts/wipe_jenkins.sh /opt/
    )
    docker images | grep -- jervis-docker-jvm || (
      cd /usr/local/src
      git clone https://github.com/samrocketman/docker-jenkins-jervis.git
      cd docker-jenkins-jervis/jervis-docker-jvm/
      docker build -t jervis-docker-jvm .
    )


    # install jenkins master
    yum localinstall -y /vagrant/build/distributions/*.rpm
    systemctl daemon-reload
    #start the Jenkins daemon
    /etc/init.d/jenkins start
    chkconfig --add jenkins
    chown jenkins. /opt/generator-cache
  SHELL
end
