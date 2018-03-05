#! /bin/bash
#
# -------------------------------------------------
# Katreena Mullican
# HudsonAlpha Institute for Biotechnology
# This code is under the MIT license, view the complete file at https://github.com/HudsonAlpha/synergy/blob/master/LICENSE
# -------------------------------------------------
# This script connects to a OneView appliance, performs a backup,
# and downloads the backup to /tmp.  The backup can then uploaded to
# Cloud storage and deleted from /tmp directory.
# -------------------------------------------------
#
# The frequency should be controlled via cronjob (i.e. run once a week every Sunday at 3 AM)
#
# -------------------------------------------------

#
# Check required packages
#
if [[ ! -f /usr/local/bin/jq && ! -f /usr/bin/jq ]] ; then
   echo
   echo "ERROR: This script requires the jq package.  Please install."
   echo
   exit 1
fi

if [[ ! -f /usr/bin/curl ]] ; then
   echo
   echo "ERROR: This script requires the curl package.  Please install."
   echo
   exit 1
fi

#
# The CRED_FILE contains a single line:
# {"userName":"xxxx","password":"xxxx"}
#
CRED_FILE=/path/to/oneview-credfile.txt
ONEVIEW_HOST=<IP address or FQDN>

#
# Check required files
#
if [[ ! -f $CRED_FILE ]] ; then
   echo
   echo "ERROR: $CRED_FILE not found.  Please create and try again."
   echo
   exit 1
fi

#
# Get the AUTH key from the OneView appliance
#
AUTHKEY=$(curl -s -k -H "X-API-Version:4" -H "Content-Type: application/json" -X POST -d @$CRED_FILE https://$ONEVIEW_HOST/rest/login-sessions | jq -r '.sessionID')

#
# Initiate the backup
#
TASK_RESOURCE=$(curl -s -k -H "auth:$AUTHKEY" -H "Accept: application/json" -H "Content-Type: application/json" -X POST https://$ONEVIEW_HOST/rest/backups/)
echo
echo "Backup initiated ... will take a few minutes."

#
# Check for completion
#
RESOURCE_URI=$(echo $TASK_RESOURCE | jq -r '.uri')
if [[ $RESOURCE_URI == "" ]] ; then
   echo
   echo "ERROR: RESOURCE_URI could not be determined.  Exiting ..."
   echo
   exit 1
fi
while true ; do
   STATUS=""
   STATUS=$(curl -s -k -H "auth:$AUTHKEY" -H "Accept: application/json" -X GET https://$ONEVIEW_HOST/$RESOURCE_URI | jq -r '.taskState')
   if [[ $STATUS == "Completed" ]] ; then
      break
   elif [[ $STATUS == "RequestFailed" ]] ; then
      echo
      echo "Backup failed. Exiting ..."
      echo
      exit 1
   else
      echo "still running ..." 
      sleep 5
   fi
done

#
# Download the backup file
#
ASSOCIATED_URI=$(echo $TASK_RESOURCE | jq -r '.associatedResourceUri')
BACKUP_FILE_URI=$(curl -s -k -H "auth:$AUTHKEY" -H "Accept: application/json" -X GET https://$ONEVIEW_HOST/$ASSOCIATED_URI | jq -r '.downloadUri')
BACKUP_FILE_NAME=$(curl -s -k -H "auth:$AUTHKEY" -H "Accept: application/json" -X GET https://$ONEVIEW_HOST/$ASSOCIATED_URI | jq -r '.id')
if [[ $BACKUP_FILE_URI == "" ]] ; then
   echo
   echo "ERROR: BACKUP_FILE_URI could not be determined. Exiting ..."
   echo
   exit 1
fi
if [[ $BACKUP_FILE_NAME == "" ]] ; then
   echo
   echo "ERROR: BACKUP_FILE_NAME could not be determined. Exiting ..."
   echo
   exit 1
fi
echo
echo "Downloading backup file locally to /tmp/$BACKUP_FILE_NAME.bkp ..."
curl -o /tmp/$BACKUP_FILE_NAME.bkp -s -f -L -k -X GET -H "accept: application/octet-stream" -H "auth: $AUTHKEY" -H "X-API-Version: 4" https://$ONEVIEW_HOST/$BACKUP_FILE_URI
echo
echo "Download complete!"

# Insert your own code here to copy /tmp/$BACKUP_FILE_NAME to your favorite cloud storage
# and delete /tmp/$BACKUP_FILE_NAME if backup to cloud successful

exit 0
