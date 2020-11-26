#!/bin/bash

#UNLOAD PLIST#

/bin/launchctl unload /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.WatchPaths.plist

/bin/launchctl unload /private/var/db/JamfWATCH/LaunchDaemons/com.github.aarondavidpolley.JamfWATCH.Daily.plist


#Remove Files#

rm -rf /private/var/db/JamfWATCH/

exit 0