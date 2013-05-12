CMS Forge
=========

Installing the Vagrant dev environment
--------------------------------------

* Install VirtualBox
* Install Vagrant
* Clone this repo
* `vagrant up`

This will take awhile for it to download the VM image,
and instal all the stuff required for the app. Get a drink!

* `vagrant provision` (There's a bug with passenger using the wrong ruby -- this reruns chef to fix it)

If it starts up with no errors
------------------------------

* `vagrant ssh`
* `cd /var/www/default`
* `bundle install`
* `rake db:create`
* `mysql -u root cmsforge_development < dump.sql`
* `rake db:migrate`
* `sudo /etc/init.d/apache2 reload` (Need to automate this -- but it works for now)
* Point your local browser to `http://localhost:8082`. Magic!
