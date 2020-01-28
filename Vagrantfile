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
      [ -r /tmp/ius.asc ] || curl -fLo /tmp/ius.asc https://repo.ius.io/RPM-GPG-KEY-IUS-7
      echo '99fd7b84543828f9489e000e1d29e948e51d2fd1dc2503232030e67e960fcbb2  /tmp/ius.asc' | sha256sum -c
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
      # because docker needs to stop adding shit options to their systemd
      # service file which breaks their own daemon
      cp /usr/lib/systemd/system/docker.service /etc/systemd/system/docker.service
      sed -i -r 's#^(ExecStart=.*) -H fd:// (.*)$#\\1 \\2#' /etc/systemd/system/docker.service
      systemctl daemon-reload
      systemctl enable docker
      systemctl start docker
    )


    # install Java
    yum install -y java-1.8.0-openjdk-devel.x86_64

    # build docker image for jenkins slave
    [ -d /opt/jenkins-cache -a -d /opt/gradle-cache -a -d /opt/generator-cache ] || (
      mkdir -p /opt/jenkins-cache /opt/gradle-cache /opt/generator-cache
      chown 1000:1000 /opt/jenkins-cache /opt/gradle-cache
      mkdir -p /var/lib/jenkins
      cp -f /vagrant/scripts/wipe_jenkins.sh /opt/
    )
    docker images | grep -- jervis-docker-jvm || (
      cd /usr/local/src
      [ -d docker-jenkins-jervis ] || git clone https://github.com/samrocketman/docker-jenkins-jervis.git
      cd docker-jenkins-jervis/ubuntu1604/
      docker build -t jervis-docker-jvm .
    )


    # install jenkins master
    yum localinstall -y /vagrant/build/distributions/*.rpm
    systemctl daemon-reload
    #start the Jenkins daemon
    /etc/init.d/jenkins start
    chkconfig --add jenkins

    #some final steps
    chown jenkins. /opt/generator-cache
    ln -s /opt/generator-cache /var/lib/jenkins/.gradle
  SHELL
end
