#!/bin/tclsh

source operations/rooms/roomScripts.tcl

if { [catch { array set postData [httptool::request::parsePost] } error ] } {
  error [openapi::createError 400 "Bad request" "Invalid data: $error"]
} else {
  if { [info exists postData(name)] == 0 } {
    error [openapi::createError 400 "Bad request" "Room name not specified"]
  }

  set hm_script [hmscript_newRoom]

  set args(sRoomName) $postData(name)
  array set output [hmscript::runWithResult $hm_script args]
  lappend header "Location" [httptool::request::resolvePath "$resource/$output(ID)"]

  httptool::response::sendWithStatusAndHeaders 201 "Created" $header $output(STDOUT)
}

