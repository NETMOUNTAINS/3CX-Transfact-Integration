
#!/bin/sh

# 3CX-Transfact Recordings Submission BETA 1
# © 08/2020 by S.Reugels <s.reugels@netmountains.de>

# This script was created for the interface between
# 3CX Phone System and Transfact.
# It transmits call records after the call has ended.
# You will need to enter the API information below.

#--------------------------------------------------

API_URL="XXXXXXXXXXXXXXXXXXXXXX"
MANDANT_ID="XXXX"
ACCESS_KEY="XXXXXXXXXX"

# Password for user "phonesystem" can be found in /var/lib/3cxpbx/Bin/3CXPhoneSystem.ini
PGPASSWORD="XXXXXXXXX"

# Default instance path, only modify in custom infrastructures
MONITORDIR="/var/lib/3cxpbx/Instance1/Data/Recordings"

#--------------------------------------------------
# Checking required packages
#--------------------------------------------------

REQUIRED_PKG="inotify-tools"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi

#---------------------------------------------------
export PGPASSWORD
echo "Starting call monitoring."
inotifywait -q -m -r -e close_write --format '%w%f' "${MONITORDIR}" | while read -r NEWFILE
do
        sleep 2
        AGENT=$(echo ${NEWFILE} | rev | cut -d"/" -f2  | rev)
        FILE=$AGENT"/"$(echo ${NEWFILE} | rev | cut -d"/" -f1  | rev)
        DB_TIME=`psql -X -A -d database_single -U phonesystem -h localhost -p 5432 -t -c "SELECT start_time FROM cl_participants WHERE recording_url = '${FILE}'"`
        TIMESTAMP=$(date -d "${DB_TIME}" +%Y%m%d%H%M%S -u)
        CALLUID=$TIMESTAMP$AGENT
        echo "Detected new ended call from agent $AGENT. Starting conversion"
        ( lame -V 6 --quiet "${NEWFILE}" "/tmp/$CALLUID.mp3"
        echo "Finished conversion ID $CALLUID. Uploading now."
        sleep 5
        curl -X POST "${API_URL}" -F "modus=CALLEND" -F "audioFile=@/tmp/${CALLUID}.mp3;type=audio/mpeg3" -F "uniqueid=${CALLUID}" -F "mandantId=${MANDANT_ID}" -F "accesskey=${ACCESS_KEY}"
        echo "Finished upload. Cleaning up now."
        rm "/tmp/${CALLUID}.mp3"
        echo "Finished cleaning. Done.") &
done
