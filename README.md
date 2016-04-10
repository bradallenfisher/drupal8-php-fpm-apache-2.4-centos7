# DRUPAL 8 on php-fpm-apache-2.4
# Before running this ...

## Vagrant
Please add the following to your /etc/hosts file
``` bash
192.168.8.8     drupal8.phpfpm.dev
```

Then Run:
```bash
git clone https://github.com/bradallenfisher/drupal8-php-fpm-apache-2.4-centos7.git; cd drupal8-php-fpm-apache-2.4-centos7; vagrant up
```
## This is not fully ready yet for production. You can however, play with in on digital ocean or linode for example on RHEL based OS. 
## PROD
```bash
yes | yum -y install git && git clone https://github.com/bradallenfisher/drupal8-php-fpm-apache-2.4-centos7.git && cd drupal8-php-fpm-apache-2.4-centos7 && chmod 700 install/prod.sh && install/prod.sh
```
## I recommend updating your ssh port and also changing the firewalld rules in prod.sh 
You can find it on line 75 of /install/prod.sh
