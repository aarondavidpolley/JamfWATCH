#!/bin/sh
 
#Context: This should be a script in Jamf Pro assigned to/run via a Policy
#Purpose: Verify a computer is communicating with the JSS correctly & quickly
#Policy Scope: All Computers & All Users
#Policy Site: None/All
#Policy Frequency: Ongoing
#Policy Custom Trigger: JamfWATCHCheck
#Example Command to Run on Client Machine:
#	/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}'

echo "up"
 
exit 0