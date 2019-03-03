#!/bin/tclsh

source operations/notifications/notificationScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hm_script [hmscript_deleteNotification $id]
  hmscript::run $hm_script
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}