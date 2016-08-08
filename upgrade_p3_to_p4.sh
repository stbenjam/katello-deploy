#!/bin/bash

katello-service stop

# Upgrade puppet 3 to puppet 4
yum -y localinstall https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm # puppet 4!!!
yum remove -y puppet-server # remove old style puppet master
yum -y install puppetserver #this upgrades puppet, replaces agent too

# Copy puppet environments
cp -rfp /etc/puppet/environments/* /etc/puppetlabs/code/environments

# Restore puppet 3 info - ssl certs and cache data
mv /var/lib/puppet/ssl /etc/puppetlabs/puppet
mv /var/lib/puppet/foreman_cache_data /opt/puppetlabs/puppet/cache/

# Disable HTTP puppet to free up port
rm -f /etc/httpd/conf.d/25-puppet.conf
sed -ie '/Listen 8140/d' /etc/httpd/conf/ports.conf
service httpd restart

# we need "puppet help strings" to work so kafo_parsers picks up the parser
/opt/puppetlabs/bin/puppet module install puppetlabs-strings
/opt/puppetlabs/puppet/bin/gem install yard

# patches needed:
cd /;
curl http://paste.fedoraproject.org/397071/35937146/raw/ | patch -p0 # hack passenger module issue
curl http://paste.fedoraproject.org/397340/46980677/raw/ | patch -p0 # hack env dir override


# Expose server type https://github.com/Katello/puppet-capsule/pull/90
cd /usr/share/katello-installer-base/modules/capsule
wget https://github.com/Katello/puppet-capsule/pull/90.patch
git apply 90.patch


# Run installer again
foreman-installer -v \
  --capsule-puppet-server-implementation=puppetserver \
  --reset-foreman-puppet-home \
  --reset-foreman-puppet-ssldir \
  --reset-foreman-proxy-puppet-ssl-ca \
  --reset-foreman-proxy-puppet-ssl-cert \
  --reset-foreman-proxy-puppet-ssl-key \
  --reset-foreman-proxy-puppetdir \
  --reset-foreman-proxy-ssldir \
  --reset-foreman-puppet-home

service foreman-proxy restart
hammer -u admin -p changeme proxy refresh-features --name $HOSTNAME

# P4 client should run successfully:
/opt/puppetlabs/bin/puppet agent --test
