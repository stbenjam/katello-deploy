#!/bin/bash

# This script creates a puppet 3 katello that is ready for upgrade to puppet 4

yum -y localinstall http://yum.theforeman.org/releases/1.12/el7/x86_64/foreman-release.rpm
yum -y localinstall http://fedorapeople.org/groups/katello/releases/yum/3.1/katello/el7/x86_64/katello-repos-latest.rpm
yum -y localinstall https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm # puppet 3
yum -y localinstall http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install foreman-release-scl
yum -y install katello
yum -y install puppet

yum install -y haveged; service haveged start # saves some time on tomcat startup, worth it:)

setenforce 0  # uggggh! stopdisablingselinux.com :-P

# XXX: this will go away on its own after we are using nightlies instead of 3.1
mkdir /usr/share/katello-installer-base/modules/OLD
for r in certs katello pulp qpid crane capsule candlepin common service_wait; do
  mv /usr/share/katello-installer-base/modules/$r /usr/share/katello-installer-base/modules/OLD/
  git clone https://github.com/Katello/puppet-$r /usr/share/katello-installer-base/modules/$r
done

# remove once nightlies are back
cd /usr/share/katello-installer-base/
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/380.patch | patch -p1
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/381.patch | patch -p1
