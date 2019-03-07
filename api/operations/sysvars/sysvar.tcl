#!/bin/tclsh

source operations/sysvars/sysvarScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hmscript [hmscript_sysvar $id]

  httptool::response::send [hmscript::run $hmscript]
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}