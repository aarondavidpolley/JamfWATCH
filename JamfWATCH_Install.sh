#!/bin/bash

#Context: This should be a script in Jamf Pro assigned to/run via a Policy
#Purpose: Create and load the files needed to monitor and self heal Jamf Pro enrolment if framework is removed
#Policy Scope: All Computers & All Users (or just user/device groups where users have admin rights)
#Policy Site: None/All or inline with above
#Policy Frequency: Once Per Computer
#Policy Trigger: Check-In or Enrolment or Start-Up

#How to get Invitation ID?#

#On any macOS device, use the Jamf Recon.app to generate a quick add package with the
#correct settings for enrolment including management account, SSH settings, etc
#Then, use composer or similar tool to extract the post-install script
#Near the end of the script will be a multi-use enrolment ID like the one seen below
#Replace the one below with your invitation ID from the QuickAdd package
#IMPORTANT: do not generate your QuickAdd package from the User Initiated Enrolment Page
#This will give you a one time enrolment ID which will not work for this use case
#Only use an ID found in a recon generated QuickAdd package

#Define Variables#

#Note: make sure to edit between the "" quotes. Leave all other formatting intact
#Include port number in URL and do not use ending slash as per example below

JamfProURLinsert='JamfProURL="https://jamfpro.mycompany.com:8443"'
InvitationIDinsert='InvitationID="56186073070322895268787070779579085172"'


#############################################################################
####### NO EDITING BEYOND THIS POINT ########################################
#############################################################################


#Check for PLIST folder and create#

if [ ! -d "/private/var/db/JamfWATCH/LaunchDaemons/" ]; then

	mkdir -p "/private/var/db/JamfWATCH/LaunchDaemons/"
	
fi

#Create WatchPaths PLIST#

tee /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist <<\EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
       <string>com.github.aarondavidpolley.JamfWATCH.WatchPath</string>
    <key>ProgramArguments</key>
    <array>
	   <string>/private/var/db/JamfWATCH/Scripts/JamfWATCH.sh</string>
    </array>
    <key>WatchPaths</key>
    <array>
       <string>/Library/Application Support/JAMF/</string>
       <string>/usr/local/jamf/bin/jamf</string>
    </array>
</dict>
</plist>

EOF

#Create Daily PLIST#

tee /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist <<\EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
       <string>com.github.aarondavidpolley.JamfWATCH.Daily</string>
    <key>ProgramArguments</key>
    <array>
	   <string>/private/var/db/JamfWATCH/Scripts/JamfWATCH.sh</string>
    </array>
    <key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>12</integer>
		<key>Minute</key>
		<integer>0</integer>
	</dict>
</dict>
</plist>

EOF

#Set PLIST Permissions#

chown root:wheel /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist

chmod 644 /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist

chown root:wheel /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist

chmod 644 /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist

#LOAD PLIST#

/bin/launchctl unload /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist

/bin/launchctl load /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist

/bin/launchctl unload /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist

/bin/launchctl load /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist

#Check for Script folder and create#

if [ ! -d "/private/var/db/JamfWATCH/Scripts/" ]; then

	mkdir -p "/private/var/db/JamfWATCH/Scripts/"
	
fi

#Create Script#

tee /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh <<EOF

#!/bin/bash

#Define Variables

EOF

echo $JamfProURLinsert >> /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh
echo $InvitationIDinsert >> /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh


tee -a /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh <<\EOF


log_file="/private/var/log/JamfWATCH.log"

#---Redirect output to log---#
exec >> $log_file 2>&1

#Sleep for 20 seconds#

echo "****************************************"
date
echo "Script started, sleeping for 20 seconds"

sleep 20

#Check in with JSS#

if [ ! -e /usr/local/jamf/bin/jamf ]; then

JamfWATCHCheck="Binary Missing"

echo $JamfWATCHCheck

else

JamfWATCHCheck=$(/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}')

if [ "$JamfWATCHCheck" == "up" ]; then

echo "Jamf binary was able to communicate with the JSS"

echo "Script Complete"
date
echo "****************************************"

exit 0

fi

fi

#Run re-manage if JSS NOT responding as expected#

if [ -e /usr/local/jamf/bin/jamf ]; then

/usr/local/jamf/bin/jamf manage

else

echo "Binary Missing"

fi

sleep 3

#Check again with JSS#

if [ ! -e /usr/local/jamf/bin/jamf ]; then

JamfWATCHCheck2="Binary Missing"

echo $JamfWATCHCheck2

else

JamfWATCHCheck2=$(/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}')

if [ "$JamfWATCHCheck2" == "up" ]; then

echo "Jamf binary was able to communicate with the JSS"

echo "Script Complete"
date
echo "****************************************"

exit 0

fi

fi


#Run re-install if JSS NOT responding as expected#

#Downloading the jamf binary from the Jamf Pro server
curl -ks $JamfProURL/bin/jamf -o /tmp/jamf

#Creating the required directories
mkdir -p /usr/local/jamf/bin /usr/local/bin

#Moving the jamf binary to the correct location
mv /tmp/jamf /usr/local/jamf/bin

#Making the jamf binary executable
chmod +x /usr/local/jamf/bin/jamf

#Creating a symbolic link
ln -s /usr/local/jamf/bin/jamf /usr/local/bin

#Creating the configuration file
/usr/local/jamf/bin/jamf createConf -k -url $JamfProURL

#Enrolling the computer
/usr/local/jamf/bin/jamf enroll -invitation $InvitationID -noPolicy
enrolled=$?
if [ $enrolled -eq 0 ]
then
  /usr/local/jamf/bin/jamf update
  /usr/local/jamf/bin/jamf policy -event enrollmentComplete
  enrolled=$?
fi

echo "Enrolled: $enrolled"

sleep 3 

#Check again with JSS#

if [ ! -e /usr/local/jamf/bin/jamf ]; then

JamfWATCHCheck3="Binary Missing"

echo $JamfWATCHCheck3

else

JamfWATCHCheck3=$(/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}')

if [ "$JamfWATCHCheck3" == "up" ]; then

echo "Jamf binary was able to communicate with the JSS"

fi

fi

echo "Script Complete"
date
echo "****************************************"

exit 0


EOF


#Set Script Permissions#

chown root:wheel /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh 

chmod 755 /private/var/db/JamfWATCH/Scripts/JamfWATCH.sh 

