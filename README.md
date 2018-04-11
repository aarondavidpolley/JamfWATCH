# JamfWATCH

Jamf Pro WATCH Dog: Monitor and self heal Jamf Pro enrolment if framework is removed from a client computer

//How To Install//

Add the Install and Check script to your Jamf Pro Server and assign to polices as noted below

//Install Script//
#Context: This should be a script in Jamf Pro assigned to/run via a Policy
#Purpose: Create and load the files needed to monitor and self heal Jamf Pro enrolment if framework is removed
#Policy Scope: All Computers & All Users (or just user/device groups where users have admin rights)
#Policy Site: None/All or inline with above
#Policy Frequency: Once Per Computer
#Policy Trigger: Check-In or Enrolment or Start-Up

#Define Variables#

1. Jamf Pro URL
2. Invitation ID

#Note: make sure to edit between the "" quotes. Leave all other formatting intact
#Include port number in URL and do not use ending slash as per examples in the script

#How to get Invitation ID?#

#On any macOS device, use the Jamf Recon.app to generate a quick add package with the
#correct settings for enrolment including management account, SSH settings, etc
#Then, use composer or similar tool to extract the post-install script
#Near the end of the script will be a multi-use enrolment ID like the one seen below
#Replace the one below with your invitation ID from the QuickAdd package
#IMPORTANT: do not generate your QuickAdd package from the User Initiated Enrolment Page
#This will give you a one time enrolment ID which will nto work for this use case
#Only use an ID found in a recon generated QuickAdd package


//Check Script//
#Context: This should be a script in Jamf Pro assigned to/run via a Policy
#Purpose: Verify a computer is communicating with the JSS correctly & quickly
#Policy Scope: All Computers & All Users
#Policy Site: None/All
#Policy Frequency: Ongoing
#Policy Custom Trigger: JamfWATCHCheck
#Example Command to Run on Client Machine:
#	/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}'
