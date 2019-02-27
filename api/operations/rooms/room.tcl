#!/bin/tclsh

source operations/rooms/roomScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hmscript [hmscript_room $id $flatten $withState]
  httptool::response::send [hmscript::run $hmscript]
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}