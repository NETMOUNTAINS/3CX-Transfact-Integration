
#!/bin/sh

# 3CX-Transfact Recordings Submission v1.0
# © 08/2020 by S.Reugels <s.reugels@netmountains.de>

# This script was created for the interface between
# 3CX Phone System and Transfact.
# It transmits call records after the call has ended.
# You will need to enter the API information below.

#--------------------------------------------------

API_URL=""
MANDANT_ID=""
ACCESS_KEY=""

# Default instance path, only modify in custom infrastructures
MONITORDIR="/var/lib/3cxpbx/Instance1/Data/Recordings"

#--------------------------------------------------
# Checking required packages
#--------------------------------------------------

REQUIRED_PKG="inotify-tools"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "is installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG 
fi

#---------------------------------------------------
echo "Starting call monitoring."
inotifywait -m -r -e close_write --format '%w%f' "${MONITORDIR}" | while read NEWFILE
do
        AGENT=$(echo ${NEWFILE} | rev | cut -d"/" -f2  | rev)
        TIMESTAMP=$(echo ${NEWFILE} | rev | cut -d"_" -f1 | rev | cut -d"(" -f1)
        UID=$TIMESTAMP$AGENT
        echo "Detected new ended call from agent $AGENT. Starting conversion"
        lame -V 6 --quiet "${NEWFILE}" "/tmp/$UID.mp3"
        echo "Finished conversion ID $UID. Uploading now."
        sleep 2
        curl -X POST "${API_URL}" -F "modus=CALLEND" -F "audioFile=@/tmp/${UID}.mp3;type=audio/mpeg3" -F "uniqueid=${UID}" -F "mandantId=${MANDANT_ID}" -F "accesskey=${ACCESS_KEY}"
        echo "Finished upload. Cleaning up now."
        rm "/tmp/${UID}.mp3"
        echo "Finished cleaning. Done."
done
