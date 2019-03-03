#!/bin/tclsh

source operations/devices/deviceScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hm_script [hmscript_device $id $flatten $withState]
  httptool::response::send [hmscript::run $hm_script]
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}