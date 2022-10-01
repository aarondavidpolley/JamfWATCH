# JamfWATCH

Jamf Pro WATCH Dog: Monitor and self heal Jamf Pro enrolment if framework is removed from a client computer

Last tested with Jamf Pro 10.41.0-t1661887915 & macOS 12.6

Note: any User Initiated Enrollment devices re-enrolled via this method will NOT have user approved MDM (UAMDM) status automatically on macOS 10.15 or lower and will not have the MDM profile re-installed on macOS 11 or higher. For best results use on macOS devices enrolled via Automated Device Enrollment AKA DEP with MDM profile removal disabled.

## //How To Install//

Add the Install and Check script to your Jamf Pro Server and assign to polices as noted below

## //Install Script//
<br />#Context: This should be a script in Jamf Pro assigned to/run via a Policy
<br />#Purpose: Create and load the files needed to monitor and self heal Jamf Pro enrolment if framework is removed
<br />#Policy Scope: All Computers & All Users (or just user/device groups where users have admin rights)
<br />#Policy Site: None/All or inline with above
<br />#Policy Frequency: Once Per Computer
<br />#Policy Trigger: Check-In or Enrolment or Start-Up

### Define Variables

1. Jamf Pro URL
2. Invitation ID

<br />#Note: make sure to edit between the "" quotes. Leave all other formatting intact
<br />#Include port number in URL and do not use ending slash as per examples in the script

### How to get Invitation ID? OLD WAY

<br />#On any macOS device, use the Jamf Recon.app to generate a quick add package with the
<br />#correct settings for enrolment including management account, SSH settings, etc
<br />#Then, use composer or similar tool to extract the post-install script
<br />#Near the end of the script will be a multi-use enrolment ID like the one seen below
<br />#Replace the one below with your invitation ID from the QuickAdd package
<br />#IMPORTANT: do not generate your QuickAdd package from the User Initiated Enrolment Page
<br />#This will give you a one time enrolment ID which will not work for this use case
<br />#Only use an ID found in a recon generated QuickAdd package

### How to get Invitation ID? NEW WAY

<br />As Recon is being deprecated in a future release of Jamf Pro I now suggest to use the API to get the ID.
<br />Head to https://yourJAMFPROserver/classicapi/doc/#/computerinvitations/findComputerInvitations and authenticate to the swagger UI.
<br />Use the "Try It Out" feature to get a list of invitiations.  Look for "invitation_type":"DEFAULT" and copy the long numeric "invitation" string before it.


## //Check Script//
<br />#Context: This should be a script in Jamf Pro assigned to/run via a Policy
<br />#Purpose: Verify a computer is communicating with the JSS correctly & quickly
<br />#Policy Scope: All Computers & All Users
<br />#Policy Site: None/All
<br />#Policy Frequency: Ongoing
<br />#Policy Custom Trigger: JamfWATCHCheck
<br />#Example Command to Run on Client Machine:
<br />#	`/usr/local/jamf/bin/jamf policy -event JamfWATCHCheck | grep "Script result" | awk '{print $3}'`

## //Testing & Logs//

Once the scripts and polices have been created in Jamf Pro, enrol a testing machine into your Jamf Pro Server, install JamfWATCH, and then run:

`sudo jamf removeFramework`

If JamfWATCH is installed correctly, the log at `/var/log/JamfWATCH.log` will start populating its activities immediately
