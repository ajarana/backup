#!/bin/bash

source /home/andres/.profile

function backupCloudFilesAndPasswordManger {
  ls $LOCAL_STORAGE_LOCATION

  # Removes oldest modified files first. At its upper limit, the folder will have MAXIMUM_NUMBER_OF_FILES_ALLOWED + 1 files.
  MAXIMUM_NUMBER_OF_FILES_ALLOWED=100
  ls -tp $PASSWORD_MANAGER_LOCATION/* | grep -v '/$' | tail -n +$MAXIMUM_NUMBER_OF_FILES_ALLOWED | xargs -I {} rm -- {}

  # Backs up password manager
  source $BACKUP_PROJECT_LOCATION/backup-password-manager.sh

  # Backs up cloud files
  source $BACKUP_PROJECT_LOCATION/backup-cloud-files.sh
}

function checkUser {               
  status=0  

  for u in $(who | awk '{print $1}' | sort | uniq)                        
  do                                                                      
    if [ "$u" == "$1" ]; then                                   
      return 0               
    fi                                                                  
  done   

  return 1                       
}

echo $'\n'$(date)
echo "Executing bash script as \$USER: $USER"

checkUser $USER_1                        
ret_val=$?

if [ $ret_val -eq 0 ]; 
then             
  if grep -qs $LOCAL_STORAGE_LOCATION /proc/mounts; 
  then
    echo "$USER_1 is logged in, and Storage is mounted. Continuing backup script execution."

    backupCloudFilesAndPasswordManger
  else
    echo "$USER_1 is logged in, and Storage is NOT mounted. Backup script execution stopped."
  fi

  exit 0                      
else                                
  if grep -qs $LOCAL_STORAGE_LOCATION /proc/mounts; 
  then
    echo "$USER_1 is NOT logged in, and Storage is mounted. Continuing backup script execution."

    backupCloudFilesAndPasswordManger
  else
    echo "$USER_1 is NOT logged in, and Storage is NOT mounted. Backup script execution stopped."
  fi

  exit 1                       
fi