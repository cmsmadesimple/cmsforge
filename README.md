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

If it fails the first time, run it again before thinking it's
broken. There's a weird ruby path issue w/ Passenger that 
I haven't figured out yet.

If it starts up with no errors
------------------------------

* `vagrant ssh`
* `cd /var/www/default`
* `bundle install`
* `rake db:create`
* `mysql -u root cmsforge_development < dump.sql`
* `rake db:migrate`
* Point your local browser to `http://localhost:8082`. Magic!
