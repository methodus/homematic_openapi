#!/bin/tclsh

################
# Load modules #
################
source /www/once.tcl
sourceOnce tools/file.tcl
sourceOnce tools/json.tcl
sourceOnce tools/http.tcl
sourceOnce tools/openapi.tcl
sourceOnce tools/hmscript.tcl

if { [catch {
  array set queryArgs [httptool::request::parseQuery]
  
  set resource /$queryArgs(resource)

  set flatten 0
  if { [info exists queryArgs(flatten)] } {
    set flatten queryArgs(flatten)
  }

  set withState 0
  if { [info exists queryArgs(withState)] } {
    set withState queryArgs(withState)
  }

  set method   [httptool::request::method]

  openapi::loadOperations operations.conf

  array set operation [openapi::matchResourcePath $resource]
  source [file join "operations/" "$operation($method).tcl"]
} err ] } {
  if { [catch { array set errDetails $err } err2] || 0 == [info exists errDetails(CODE)] } {
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