#!/bin/tclsh
##
# openapi.tcl
# OpenAPI tools.
##

namespace eval openapi {

  variable operations

  proc loadOperations { fname } {
    variable operations
    array set operations [file::load $fname]
  }

  proc createError { code status message } {
    set error {}
    lappend error CODE $code
    lappend error STATUS $status
    lappend error MESSAGE $message
    return $error
  }

  proc matchResourcePath { path } {
    variable operations
    foreach name [array names operations] {
      if { 0 != [string match $name $path] } {
        return $operations($name)
      }
    }

    return -code error [createError 400 "Bad request" "Operation for $path not found"]
  }

}