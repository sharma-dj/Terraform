#!/bin/bash

cd backups

restorefolder="/tmp"
logfile="$restorefolder/"restore_log_"$(date +'%Y_%m')".txt
echo "restore started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

themes=`sudo aws s3 ls s3://my-test-s3-tf-bucket/ | grep '\themes.zip$' | sort | tail -n 1 | awk '{print $4}'`
plugins=`sudo aws s3 ls s3://my-test-s3-tf-bucket/ | grep '\plugins.zip$' | sort | tail -n 1 | awk '{print $4}'`
uploads=`sudo aws s3 ls s3://my-test-s3-tf-bucket/ | grep '\uploads.zip$' | sort | tail -n 1 | awk '{print $4}'`
database=`sudo aws s3 ls s3://my-test-s3-tf-bucket/ | grep '\db.sql.gz$' | sort | tail -n 1 | awk '{print $4}'`

echo "Theme: $themes, Plugin: $plugins, Database: $database, Uploads: $uploads" >> "$logfile"

sudo aws s3 cp s3://my-test-s3-tf-bucket/$themes .
sudo aws s3 cp s3://my-test-s3-tf-bucket/$plugins .
sudo aws s3 cp s3://my-test-s3-tf-bucket/$database .
sudo aws s3 cp s3://my-test-s3-tf-bucket/$uploads .

# restore themes directory
echo "themes restore started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo unzip $themes
sudo rm -rf /var/www/html/wp-content/themes/
sudo mv themes/ /var/www/html/wp-content/
sudo chmod 777 /var/www/html/wp-content/themes
echo "themes restore ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# restore plugins directory
echo "plugins restore started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo unzip $plugins
sudo rm -rf /var/www/html/wp-content/plugins/
sudo mv plugins /var/www/html/wp-content/
sudo chmod 777 /var/www/html/wp-content/plugins
echo "plugins restore ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# restore uploads directory
echo "uploads restore started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo unzip $uploads
sudo rm -rf /var/www/html/wp-content/uploads/
sudo mv uploads /var/www/html/wp-content/
sudo chmod 777 /var/www/html/wp-content/uploads
echo "uploads restore ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# restore database
WPDBNAME=`cat /var/www/html/wp-config.php | grep DB_NAME | cut -d \' -f 4`
WPDBUSER=`cat /var/www/html/wp-config.php | grep DB_USER | cut -d \' -f 4`
WPDBPASS=`cat /var/www/html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
echo "database restore started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo gunzip < "$database" | mysql --user=$WPDBUSER --password=$WPDBPASS $WPDBNAME
echo "database restore ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
# remove all backup files
echo "backup files cleanup started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo rm -rf themes
sudo rm -rf plugins
sudo rm -rf uploads
sudo rm $database
sudo rm *.zip
echo "backup files cleanup ended at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "*****************" >> "$logfile"
exit 0
