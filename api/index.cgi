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
sourceOnce tools/session.tcl

if { [catch {
  openapi::loadOperations operations.conf

  array set queryArgs [httptool::request::parseQuery]

  if { [catch { array set cookieData [httptool::request::parseCookies] } error ] } {
      error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  }

  set flatten 0
  if { [info exists queryArgs(flatten)] } {
    set flatten $queryArgs(flatten)
  }

  set withState 0
  if { [info exists queryArgs(withState)] } {
    set withState $queryArgs(withState)
  }

  set resource /$queryArgs(resource)
  set method   [httptool::request::method]
  array set operation [openapi::findOperation $resource $method]

  set SID ""
  if { [info exists cookieData(SID)] } {
    set SID $cookieData(SID)
  }
  session_checkPermissions $SID $operation(PERMS)

  source [file join "operations/" "$operation(SCRIPT).tcl"]
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