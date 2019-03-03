#!/bin/tclsh

source operations/notifications/notificationScripts.tcl

set hm_script [hmscript_deleteNotifications]
hmscript::run $hm_script
httptool::response::sendWithStatus 204 "No Content"