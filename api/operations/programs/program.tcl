#!/bin/tclsh

source operations/programs/programScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sProgramId) $id
  set output [hmscript::run [hmscript_program] args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}