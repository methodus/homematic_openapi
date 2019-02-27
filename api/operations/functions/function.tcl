#!/bin/tclsh

source operations/functions/functionScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set hmscript [hmscript_function $id $flatten $withState]
  httptool::response::send [hmscript::run $hmscript]
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}