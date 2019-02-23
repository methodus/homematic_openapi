#!/bin/tclsh

source operations/channels/channelScripts.tcl

set hm_script [hmscript_channel]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sChannelId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}