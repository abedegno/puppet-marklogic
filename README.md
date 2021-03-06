puppet-marklogic
================
![Build Status](https://travis-ci.org/myoung34/puppet-marklogic.png?branch=master,dev)&nbsp;[![Coverage Status](https://coveralls.io/repos/myoung34/puppet-marklogic/badge.png)](https://coveralls.io/r/myoung34/puppet-marklogic)&nbsp;[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/myoung34/puppet-marklogic/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Puppet Module For Marklogic

About
=====

[MarkLogic](http://www.marklogic.com) is an Enterprise level NoSQL XML database driven to big data. It supports Windows, OSX, and RHEL/CentOS distributions, while this module is aimed at CentOS only (untested on RHEL).

Known AWS Issues
=================

[See this for a detailed explanation](https://github.com/myoung34/puppet-marklogic/wiki/Permanent-AWS-Issue)

Supported Versions (tested)
=================
## OS ##
* CentOS 6
    * MarkLogic Base install (MarkLogic not pre-installed)
        * 6.0-1.1 
        * 6.0-2.3 
        * 6.0-4
        * 6.0-4.1
        * 7.0-1
    * MarkLogic Upgrades 
        * 6.0.1.1 *to* 6.0.2.3
        * 6.0.1.1 *to* 6.0.4
        * 6.0.1.1 *to* 6.0.4.1
        * 6.0.1.1 *to* 7.0-1
        * 6.0.2.3 *to* 6.0.4
        * 6.0.2.3 *to* 6.0.4.1
        * 6.0.2.3 *to* 7.0-1
        * 6.0.4   *to* 6.0-4.1
        * 6.0.4   *to* 7.0-1
        * 6.0.4.1 *to* 7.0-1

Prerequisites
=============

1. Yum repository with MarkLogic RPMs available (The EULA does not allow redistribution)
1. Valid license information

Quick Start
===========

       yumrepo { "my ML repo":
          baseurl  => "http://server/pulp/repos/marklogic/",
          descr    => "My MarkLogic Repository",
          enabled  => 1,
          gpgcheck => 0,
        }
        class { 'marklogic':
          admin_user             => 'admin', #defaults to admin
          admin_password         => 'admin', #defaults to admin
          disable_ec2_detection  => true,    #defaults to false
          is_development_license => true,    #defaults to false
          is_upgrade             => false,   #defaults to false
          licensee               => 'myname',#required
          license_key            => 'mykey', #required
          version                => '6.0-4', #required
        }

Hiera
=====

    marklogic::admin_password:         'admin'
    marklogic::admin_user:             'admin'
    marklogic::disable_ec2_detection:  true
    marklogic::is_development_license: true
    marklogic::is_upgrade:             false
    marklogic::licensee:               'my licensee'
    marklogic::license_key:            'my key'
    marklogic::version:                '6.0-4'
    
Testing
=====

Due to licensing issues, I cannot distribute the base Vagrant .box that contains the Yum repo.

Also due to licensing, I cannot distribute the required license information to get the tests to run.

If you wish to run the tests:

* create the file **~/.marklogic.yml** which contains:

        licensee: 'my licensee info'
        license_key: 'my key'
        is_development_license: true

* Create a matching Vagrant box

         vagrant box add base http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box
         vagrant init
         vagrant up
         vagrant ssh 
         sudo mkdir /usr/share/marklogic && sudo chmod 777 /usr/share/marklogic -R
         exit
         # scp -P 2222 -r ~/rpms/marklogic/*.rpm vagrant@localhost:/usr/share/marklogic/ #put your RPMs into the vm
         vagrant ssh 
         sudo yum install -y createrepo
         cd /usr/share/marklogic && createrepo .
         sudo su -
         echo $'[marklogic]\nname=MarkLogic CentOS-$releasever\nbaseurl=file:///usr/share/marklogic/\ngpgcheck=0\nenabled=1' > /etc/yum.repos.d/marklogic.repo
         rm -f /etc/sysconfig/network-scripts/ifcfg-eth1
         rm -f /etc/udev/rules.d/70-persistent-net.rules # see: https://github.com/mitchellh/vagrant/issues/921
         exit
         exit
         vagrant package --output CentOS_64_x86-64_MarkLogic_YUM.box
         vagrant box add centos-64-x64-ml-yum CentOS_64_x86-64_MarkLogic_YUM.box

* Run the default tests (puppet + lint)

        bundle install
        bundle exec rake
        
* Run the system install tests individually

        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6011-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6023-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-604-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-701-yum spec:system
        
* Run the system upgrade tests individually

        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6011-6023-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6011-604-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6011-701-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6023-604-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-6023-701-yum spec:system
        $ bundle exec rake RSPEC_SET=centos-64-x64-ml-604-701-yum spec:system

* Run every. single. test.

        $ for i in `cat .nodeset.yml | shyaml get-value sets| grep -E '^[a-zA-Z]' | sed 's/://g'`; do echo $i; bundle exec rake RSPEC_SET=$i spec:system | grep -A 1 -E '^Finished in'; done

* Running without upgrade tests
  * Remove ```nextVersion: '...'``` from the node you want to test
