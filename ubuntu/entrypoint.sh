#!/usr/bin/bash -x

service mysql start

mysql -uroot -e "create database redmine character set utf8mb4;"
mysql -uroot -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine';"
mysql -uroot -e "grant all privileges on redmine.* to 'redmine'@'localhost';"

cd /opt/redmine
export RAILS_ENV=production
export REDMINE_LANG=ja 
/usr/local/rbenv/shims/bundle exec rake generate_secret_token
/usr/local/rbenv/shims/bundle exec rake db:migrate
/usr/local/rbenv/shims/bundle exec rake redmine:load_default_data

service apache2 start

/usr/sbin/sshd -D
