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

  proc findOperation { path method } {
    variable operations
    foreach name [array names operations] {
      if { 0 != [string match $name $path] } {
        array set operation $operations($name)
        if { ![info exists operation($method)] } {
          return -code error [createError 405 "Method Not Allowed" "$method not allowed for $path"]
        }
        return $operation($method)
      }
    }

    return -code error [createError 400 "Bad request" "Operation for $method $path not found"]
  }

}