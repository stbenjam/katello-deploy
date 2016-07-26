#!/bin/bash

# *******
# This is a script to get katello installed with puppet 4. It is only meant to
# be a POC and should not be used in production scenarios.
#
# This script is temporary and should go away and be replaced with something
# better.
# *******

yum -y localinstall http://yum.theforeman.org/releases/1.12/el7/x86_64/foreman-release.rpm
yum -y localinstall http://fedorapeople.org/groups/katello/releases/yum/3.1/katello/el7/x86_64/katello-repos-latest.rpm
yum -y localinstall https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm # puppet 4!!!
yum -y localinstall http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install foreman-release-scl
yum -y install katello
yum -y install puppet-agent #this upgrades puppet


# XXX: please fix this second
setenforce 0  # uggggh! stopdisablingselinux.com :-P

/vagrant/shells/katello_p4.sh
