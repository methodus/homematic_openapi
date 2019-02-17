#!/bin/tclsh

################
# Load modules #
################
source /www/once.tcl
sourceOnce tools/json.tcl
sourceOnce tools/http.tcl
sourceOnce tools/openapi.tcl
sourceOnce tools/hmscript.tcl

if { [catch {
  set resource [httptool::request::resourcePath]
  set method   [httptool::request::method]

  openapi::loadOperations operations.conf

  array set operation [openapi::matchResourcePath $resource]
  source [file join "operations/" $operation($method)]
} err ] } {
  if { [catch { array set errDetails $err } err2] } {
    set code 500
    set status "Internal Server Error"
    set message "$status: $err"
  } else {
    set code $errDetails(CODE)
    set status $errDetails(STATUS)
    if { [info exists errDetails(MESSAGE)] } {
      set message $errDetails(MESSAGE)
    } else {
      set message $status
    }
  }

  set error {}
  JSON::Dict::addString error code $code
  JSON::Dict::addString error message $message

  httptool::response::sendWithStatus $code $status [JSON::Parser::toJSON $error]
}