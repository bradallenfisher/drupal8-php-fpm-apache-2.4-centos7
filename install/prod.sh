#!/bin/bash

# install apache
yum install unzip zip nano deltarpm vim wget curl git httpd -y

# get some repos
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm

# get latest mysql
yum install -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm 
yum install -y mysql mysql-server
systemctl enable mysqld.service
/bin/systemctl start  mysqld.service
yum update -y

# php
yum install -y --enablerepo=remi-php70 php php-apcu php-fpm php-opcache php-cli php-common php-gd php-mbstring php-mcrypt php-pdo php-xml php-mysqlnd

# varnish
rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el7.rpm
yum install -y varnish

# VARNISH
cat varnish/default.vcl > /etc/varnish/default.vcl
cat varnish/varnish.params > /etc/varnish/varnish.params

# Varnish can listen
sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf

# PHP
# The first pool
cat php/www.conf > /etc/php-fpm.d/www.conf

#opcache settings
cat php/opcache.ini > /etc/php.d/10-opcache.ini

#disable mod_php
cat php/php.conf > /etc/httpd/conf.d/php.conf

#allow for clean urls
cat html/html.conf > /etc/httpd/conf.d/html.conf

#disable some un-needed modules.
cat modules/00-base.conf > /etc/httpd/conf.modules.d/00-base.conf
cat modules/00-dav.conf > /etc/httpd/conf.modules.d/00-dav.conf
cat modules/00-lua.conf > /etc/httpd/conf.modules.d/00-lua.conf
cat modules/00-mpm.conf > /etc/httpd/conf.modules.d/00-mpm.conf
cat modules/00-proxy.conf > /etc/httpd/conf.modules.d/00-proxy.conf
cat modules/01-cgi.conf > /etc/httpd/conf.modules.d/01-cgi.conf

# BASIC PERFORMANCE SETTINGS
mkdir /etc/httpd/conf.performance.d/
cat performance/compression.conf > /etc/httpd/conf.performance.d/compression.conf
cat performance/content_transformation.conf > /etc/httpd/conf.performance.d/content_transformation.conf
cat performance/etags.conf > /etc/httpd/conf.performance.d/etags.conf
cat performance/expires_headers.conf > /etc/httpd/conf.performance.d/expires_headers.conf
cat performance/file_concatenation.conf > /etc/httpd/conf.performance.d/file_concatenation.conf
cat performance/filename-based_cache_busting.conf > /etc/httpd/conf.performance.d/filename-based_cache_busting.conf

# BASIC SECURITY SETTINGS
mkdir /etc/httpd/conf.security.d/
cat security/apache_default.conf > /etc/httpd/conf.security.d/apache_default.conf

# our domain config
mkdir /etc/httpd/conf.sites.d
echo IncludeOptional conf.sites.d/*.conf >> /etc/httpd/conf/httpd.conf
cat domains/8080-domain.conf > /etc/httpd/conf.sites.d/test.conf

# our performance config
echo IncludeOptional conf.performance.d/*.conf >> /etc/httpd/conf/httpd.conf

# our security config
echo IncludeOptional conf.security.d/*.conf >> /etc/httpd/conf/httpd.conf

# fix date timezone errors
sed -i 's#;date.timezone =#date.timezone = "America/New_York"#g' /etc/php.ini

# FIREWALL
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=22/tcp
systemctl restart firewalld.service

# Make sue services stay on after reboot

systemctl enable httpd.service
systemctl enable mysqld.service
systemctl enable php-fpm.service
systemctl enable varnish.service

# Start all the services we use.
systemctl start php-fpm.service
systemctl start  mysqld.service
systemctl start httpd.service
systemctl start varnish.service

# Install Drush globally.
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer

# Drush Local
composer global require drush/drush:8.*
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc

# Install Drupal Console
curl https://drupalconsole.com/installer -L -o drupal.phar
mv drupal.phar /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal
ln -s /usr/local/bin/drupal /usr/bin/drupal

drupal init
# install drush recipes
#drush dl drush_recipes -y
#drush dl drush_cleanup
drush cc drush

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
