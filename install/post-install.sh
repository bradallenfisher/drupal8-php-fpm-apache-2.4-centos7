#!/bin/bash

# Drush Local
composer global require drush/drush:8.*
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc

# install drush recipes
#drush dl drush_recipes -y
#drush dl drush_cleanup
drush cc drush

sudo chown -R vagrant:vagrant /var/www/
drush dl drupal-8 --destination=/var/www/ --drupal-project-rename=html -y

cd /var/www/html
drush site-install --account-pass=admin --db-url=mysql://root@localhost:22/test -y
sudo chmod -R 755 /var/www/html/sites/default/files/
sudo chown -R apache:apache /var/www/html/sites/default/files/

#start the apache service now that we have an .htaccess file
sudo systemctl start httpd.service

sudo service firewalld stop
echo "DUNZY!"
exec bash

