CMS Forge
=========

Installing the Vagrant dev environment
--------------------------------------

* Install VirtualBox 4.2.12 (4.2.14 has a bug)
* Install Vagrant 1.2.2
* Clone this repo
* `vagrant init precise32 http://files.vagrantup.com/precise32.box`
* `vagrant up`

This will take awhile for it to download the VM image,
and instal all the stuff required for the app. Get a drink!

* `vagrant provision` (There's a bug with passenger using the wrong ruby -- this reruns chef to fix it)

If it starts up with no errors
------------------------------


* `vagrant ssh` will give you more informations (password = vagrant)

* `cd /vagrant`
* `sudo apt-get update`
* `sudo apt-get upgrade`
* `sudo apt-get install ruby-bundler`
* `sudo apt-get install rails`
* `sudo apt-get install git`
* `sudo apt-get install mysql-client libmysqlclient-dev mysql-server-5.5`
* `sudo apt-get install nodejs`
* `sudo apt-get install apache2`
* `sudo apt-get install sphinxsearch`
* `sudo bundle install`
* `sudo rake db:create`
* `sudo mysql -u root cmsforge_development < dump.sql`
* `sudo rake db:migrate`
* `sudo /etc/init.d/apache2 reload` (Need to automate this -- but it works for now)
* Point your local browser to `http://localhost:8082`. Magic!
