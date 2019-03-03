#!/bin/tclsh

source operations/notifications/notificationScripts.tcl

set hm_script [hmscript_notifications]

httptool::response::send [hmscript::run $hm_script]