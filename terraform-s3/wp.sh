#!/bin/bash

backupfolder="/tmp"
logfile="$backupfolder/"terraform_log_"$(date +'%Y_%m')".txt
echo "script started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

# Install Apache
sudo apt-get -y install apache2

# Start Apache
sudo systemctl start apache2

# Enable Apache
sudo systemctl enable apache2
echo "Apache installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Install PHP
sudo apt-get update
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get -y install php7.4
echo "PHP installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Install xml and curl module
sudo apt-get install -y php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl
echo "PHP modules installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Restart Apache
sudo systemctl restart apache2

# Install MySQL
sudo apt-get -y install mysql-server
echo "Mysql server installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Start MySQL
sudo service mysql start
echo "LAMP installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Create a database with random name
DB=database_$RANDOM
DBUSERNAME=dbuser_$RANDOM
DBUSERPASS=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)
echo "DB deatails DB:$DB DBUSERNAME:$DBUSERNAME DBUSERPASS:$DBUSERPASS" >> "$logfile"
# Secure database
mysql -u root -e "CREATE USER '$DBUSERNAME'@'localhost' IDENTIFIED BY '$DBUSERPASS'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSERNAME'@'localhost' WITH GRANT OPTION"
mysql -u root -e "FLUSH PRIVILEGES"
echo "db user created at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
echo "wp-cli downloaded at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sleep 10

sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

echo "WP-CLI installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# Change directory to html
cd /var/www/html/

sudo chmod -R 777 /var/www/html/

# download the WordPress core files
sudo -u www-data wp core download
echo "WP downloaded at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

# create the wp-config file with our standard setup
sudo -u www-data wp core config --dbname=$DB --dbuser=$DBUSERNAME --dbpass=$DBUSERPASS --extra-php <<PHP
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'AUTOSAVE_INTERVAL', 300 );
define( 'WP_POST_REVISIONS', 10 );
define( 'WP_AUTO_UPDATE_CORE', false );
PHP
echo "wp-config.php created at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# random wordpress table prefix
WPTABLEPREFIX=wp$RANDOM
echo "WPTABLEPREFIX:$WPTABLEPREFIX" >> "$logfile"
sudo sed -i "s/wp_/wp32323_/g" /var/www/html/wp-config.php

# generate random 12 character password
#password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

# create database, and install WordPress
sudo -u www-data wp db create
echo "wp db created at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo -u www-data wp core install --url="https://${siteurl}" --title="${site_name}" --admin_user="${admin_username}" --admin_password="${admin_password}" --admin_email="${admin_email}"
echo "wp core installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# discourage search engines
sudo -u www-data wp option update blog_public 0

# disable show avatars
sudo -u www-data wp option update show_avatars 0

# delete posts
sudo -u www-data wp post delete $(sudo -u www-data wp post list --post_type=post --post_status=publish --field=ID --format=ids)

# delete sample page, and create homepage
sudo -u www-data wp post delete $(sudo -u www-data wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
sudo -u www-data wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(sudo -u www-data wp user get ${admin_username} --field=ID --format=ids)

# set homepage as front page
sudo -u www-data wp option update show_on_front 'page'

# set homepage to be the new page
sudo -u www-data wp option update page_on_front $(sudo -u www-data wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)

# set WordPress permalinks
sudo -u www-data wp option update permalink_structure '/%postname%'

# set pretty urls
#sudo -u www-data wp rewrite structure '/%postname%/' --hard
#sudo -u www-data wp rewrite flush --hard

# create .htaccess file
echo -e "
# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %#REQUEST_FILENAME1#
RewriteCond %#REQUEST_FILENAME2#
RewriteRule . /index.php [L]
# END WordPress

<IfModule mod_expires.c>
# Enable expirations
ExpiresActive On 
# Default directive
ExpiresDefault \"access plus 1 month\"
# My favicon
ExpiresByType image/x-icon \"access plus 1 year\"
# Images
ExpiresByType image/gif \"access plus 1 month\"
ExpiresByType image/png \"access plus 1 month\"
ExpiresByType image/jpg \"access plus 1 month\"
ExpiresByType image/jpeg \"access plus 1 month\"
# CSS
ExpiresByType text/css \"access plus 1 month\"
# Javascript
ExpiresByType application/javascript \"access plus 1 year\"
</IfModule>" > /var/www/html/.htaccess

# replace REQUEST_FILENAME placeholder
sudo sed -i "s/#REQUEST_FILENAME1#/{REQUEST_FILENAME} \!-f/g" /var/www/html/.htaccess
sudo sed -i "s/#REQUEST_FILENAME2#/{REQUEST_FILENAME} \!-d/g" /var/www/html/.htaccess

# delete akismet and hello dolly
sudo -u www-data wp plugin delete akismet
sudo -u www-data wp plugin delete hello

# If --all is set, all plugins that have updates will be updated.
sudo -u www-data wp plugin update --all

# To install and activate plugin
sudo -u www-data wp plugin install contact-form-7 --activate
sudo -u www-data wp plugin install backwpup --activate
sudo -u www-data wp plugin install maintenance

# delete default themes 
sudo -u www-data wp theme delete twentyseventeen
sudo -u www-data wp theme delete twentynineteen

# To install and activate theme
sudo -u www-data wp theme install OceanWP

# Generate a child theme based on OceanWP
sudo -u www-data wp scaffold child-theme oceanwp-child --parent_theme=oceanwp
sudo -u www-data wp theme activate oceanwp-child

# delete previous active theme
sudo -u www-data wp theme delete twentytwenty

sudo sed -i "s/oceanwp-style/parent-style/g" /var/www/html/wp-content/themes/oceanwp-child/functions.php

# add some custom functions to functions.php file of child theme
echo "
//To disable all automatic theme updates
add_filter( 'auto_update_theme', '__return_false' );
//To disable all automatic plugin updates
add_filter( 'auto_update_plugin', '__return_false' );
add_filter( 'pre_comment_content', 'wp_specialchars');
function _remove_script_version( \$src ){
	\$parts = explode( '?ver', \$src );
	return \$parts[0];
}
add_filter( 'script_loader_src', '_remove_script_version', 15, 1 );
add_filter( 'style_loader_src', '_remove_script_version', 15, 1 );
// Remove WP embed script
function speed_stop_loading_wp_embed() {
	if (!is_admin()) {
		wp_deregister_script('wp-embed');
	}
}
add_action('init', 'speed_stop_loading_wp_embed');
" >> /var/www/html/wp-content/themes/oceanwp-child/functions.php

# remove wp-config.php file to add force SSL code
sudo rm /var/www/html/wp-config.php

# re-create the wp-config file with our standard setup and force SSL code. This is important step to add force SSL code.
sudo -u www-data wp core config --dbname=$DB --dbuser=$DBUSERNAME --dbpass=$DBUSERPASS --extra-php <<PHP
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'AUTOSAVE_INTERVAL', 300 );
define( 'WP_POST_REVISIONS', 10 );
define( 'WP_AUTO_UPDATE_CORE', false );
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  \$_SERVER['HTTPS'] = 'on';
}
PHP

sudo sed -i "s/wp_/wp32323_/g" /var/www/html/wp-config.php

# /var/www/html should be owned by www-data user and permission for html folder should be 755 for www-data user
sudo chown -R www-data:www-data /var/www/html
sudo chmod 775 /var/www/html

#create uploads folder and set permissions
sudo mkdir wp-content/uploads
sudo chmod 777 wp-content/uploads

#set 777 permissions to plugins folder
sudo chmod 777 wp-content/plugins

#remove index.html file
sudo rm index.html

echo "Ready, go to http://'your ec2 url' and enter the site info to finish the installation."

sudo apt-get update

# changes to be made in php.ini
sudo sed -e '/^[^;]*upload_max_filesize/s/=.*$/= 100M/' -i.bak /etc/php/7.4/apache2/php.ini
sudo sed -e '/^[^;]*memory_limit/s/=.*$/= 256M/' -i /etc/php/7.4/apache2/php.ini
sudo sed -e '/^[^;]*post_max_size/s/=.*$/= 64M/' -i /etc/php/7.4/apache2/php.ini
sudo sed -e '/^[^;]*max_execution_time/s/=.*$/= 300/' -i /etc/php/7.4/apache2/php.ini
sudo sed -e '/^[^;]*max_input_time/s/=.*$/= 1000/' -i /etc/php/7.4/apache2/php.ini

# create a copy of 000-default.conf
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/copy-000-default.conf

# add new 000-default.conf with AllowOverride All
echo "
<VirtualHost *:80>
     ServerAdmin webmaster@localhost
     DocumentRoot /var/www/html
     <Directory /var/www/html>
          Options Indexes FollowSymLinks MultiViews
          AllowOverride All
          Order allow,deny
          allow from all
     </Directory>
     ErrorLog \$#APACHE_LOG_DIR#/error.log
     CustomLog \$#APACHE_LOG_DIR#/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

# replace APACHE_LOG_DIR placeholder
sudo sed -i "s/#APACHE_LOG_DIR#/{APACHE_LOG_DIR}/g" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s/#CustomLog#/{APACHE_LOG_DIR}/g" /etc/apache2/sites-available/000-default.conf

sudo a2enmod rewrite
sudo systemctl restart apache2

cd $HOME
sudo apt-get -y install zip

echo "AWS-CLI download started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
echo "AWS-CLI download ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
unzip awscliv2.zip
sudo ./aws/install
echo "AWS-CLI installed at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sleep 90
### create AWS config
sudo aws configure set region ${region}
sudo aws configure set output json

### create AWS credintials
sudo aws configure set aws_access_key_id ${access_key}
sudo aws configure set aws_secret_access_key ${secret_key}
echo "AWS-CLI configured at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "Setting cron-job started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo mkdir /tmp/backups
sudo chmod 777 /tmp/backups
sudo chmod +x /tmp/backup.sh
#sudo crontab -l|sed "\$a*/10 * * * * bash /tmp/backup.sh /home/root"|crontab -
echo "Setting cron-job ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "*****************" >> "$logfile"