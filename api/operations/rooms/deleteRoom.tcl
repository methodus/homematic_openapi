#!/bin/tclsh

source operations/rooms/roomScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hm_script [hmscript_deleteRoom $id]
  hmscript::runWithResult $hm_script
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}