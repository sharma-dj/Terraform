#!/bin/bash

WPDBNAME=`cat /var/www/html/wp-config.php | grep DB_NAME | cut -d \' -f 4`
WPDBUSER=`cat /var/www/html/wp-config.php | grep DB_USER | cut -d \' -f 4`
WPDBPASS=`cat /var/www/html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`

echo "$WPDBNAME"
echo "$WPDBUSER"
echo "$WPDBPASS"

now="$(date +'%d_%m_%Y_%H_%M_%S')"
filename="backup_$now-db.sql".gz
backupfolder="/tmp/backups"
fullpathbackupfile="$backupfolder/$filename"
logfile="/tmp/"backup_log_"$(date +'%Y_%m')".txt
echo "mysqldump started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
mysqldump --user=$WPDBUSER --password=$WPDBPASS --default-character-set=utf8 $WPDBNAME | gzip > "$fullpathbackupfile"
echo "mysqldump finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

THEMEBACKUPFILENAME="backup_$(date +'%d_%m_%Y_%H_%M_%S-themes')".zip
PLUGINBACKUPFILENAME="backup_$(date +'%d_%m_%Y_%H_%M_%S-plugins')".zip
UPLOADSBACKUPFILENAME="backup_$(date +'%d_%m_%Y_%H_%M_%S-uploads')".zip
cd /var/www/html/wp-content/
echo "theme backup $THEMEBACKUPFILENAME started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo zip -r $THEMEBACKUPFILENAME themes
echo "theme backup finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "plugin backup $PLUGINBACKUPFILENAME started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo zip -r $PLUGINBACKUPFILENAME plugins
echo "plugin finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "uploads backup $UPLOADSBACKUPFILENAME started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo zip -r $UPLOADSBACKUPFILENAME uploads
echo "uploads finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"

sudo mv $THEMEBACKUPFILENAME /tmp/backups/
sudo mv $PLUGINBACKUPFILENAME /tmp/backups/
sudo mv $UPLOADSBACKUPFILENAME /tmp/backups/

cd /tmp/backups/
echo "uploading backups to S3 started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo aws s3 cp . s3://my-test-s3-tf-bucket/ --recursive
echo "uploading backups to S3 finished started at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
sudo rm *.zip
sudo rm *.gz
echo "operation finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "*****************" >> "$logfile"
exit 0
