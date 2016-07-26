#!/bin/bash

# *******
# This is a script to get katello installed with puppet 4. It is only meant to
# be a POC and should not be used in production scenarios.
#
# This script is temporary and should go away and be replaced with something
# better.
# *******

# we need "puppet help strings" to work so kafo_parsers picks up the parser
/opt/puppetlabs/bin/puppet module install puppetlabs-strings
/opt/puppetlabs/puppet/bin/gem install yard

# at this point, "foreman-installer -v --noop --scenario katello" will run (not clean, but runs)

# XXX: this will go away on its own after we are using nightlies instead of 3.1
mkdir /usr/share/katello-installer-base/modules/OLD
for r in certs katello pulp qpid crane capsule candlepin common service_wait; do
  mv /usr/share/katello-installer-base/modules/$r /usr/share/katello-installer-base/modules/OLD/
  git clone https://github.com/Katello/puppet-$r /usr/share/katello-installer-base/modules/$r
done

if [ -d "/usr/share/katello-installer-base/modules/katello_devel" ]; then
  mv /usr/share/katello-installer-base/modules/katello_devel /usr/share/katello-installer-base/modules/OLD/
  git clone https://github.com/Katello/puppet-katello_devel /usr/share/katello-installer-base/modules/katello_devel
fi


# XXX: please fix this first
cd /;
curl http://paste.fedoraproject.org/397340/46980677/raw/ | patch -p0 # hack env dir override

# remove once nightlies are back
cd /usr/share/katello-installer-base/
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/380.patch | patch -p1
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/381.patch | patch -p1
