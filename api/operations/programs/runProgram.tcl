#!/bin/tclsh

source operations/programs/programScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sProgramId) $id
  hmscript::run [hmscript_runProgram] args
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}