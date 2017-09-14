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
    yum makecache fast
    yum install -y epel-release

    # install IUS repo
    [ -r /tmp/ius.asc ] || curl -fLo /tmp/ius.asc https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY
    echo '688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e  /tmp/ius.asc' | sha256sum -c
    rpm --import /tmp/ius.asc
    [ -r /tmp/ius.rpm ] || curl -fLo /tmp/ius.rpm https://centos7.iuscommunity.org/ius-release.rpm
    rpm -K /tmp/ius.rpm
    rpm -qa | grep ius-release || yum localinstall -y /tmp/ius.rpm

    # install Docker repo
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # install packages
    yum makecache
    yum install -y yum-utils device-mapper-persistent-data lvm2 git2u docker-ce
    yum install -y vim bind-utils net-tools nc
    cp /vagrant/configs/dockerd-daemon.json /etc/docker/daemon.json
    mkdir -p /etc/docker
    chmod 700 /etc/docker
    chown root. /etc/docker/daemon.json
    chmod 644 /etc/docker/daemon.json
    systemctl enable docker
    systemctl start docker

    # install Java from Oracle
    [ -r /tmp/jdk8.rpm ] || curl -H 'Cookie: oraclelicense=accept-securebackup-cookie' -Lo /tmp/jdk8.rpm http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm
    echo 'cdb016da0c509d7414ee3f0c15b2dae5092d9a77edf7915be4386d5127e8092f  /tmp/jdk8.rpm' | sha256sum -c -
    rpm -i /tmp/jdk8.rpm

    # build docker image for jenkins slave
    mkdir -p /opt/jenkins-cache /opt/gradle-cache
    chown 1000:1000 /opt/jenkins-cache /opt/gradle-cache
    pushd /usr/local/src
    git clone https://github.com/samrocketman/docker-jenkins-jervis.git
    cd docker-jenkins-jervis/jervis-docker-jvm/
    docker build -t jervis-docker-jvm .
    popd

    # install jenkins master
    rpm -i /vagrant/build/distributions/*.rpm
    mkdir /opt/generator-cache
    chown jenkins. /opt/generator-cache
    ln -s /opt/generator-cache /var/lib/jenkins/.gradle
    cp /vagrant/scripts/wipe_jenkins.sh /opt/
    #start the Jenkins daemon
    /etc/init.d/jenkins start
    chkconfig --add jenkins
  SHELL
end
