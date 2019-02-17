#!/bin/tclsh
##
# openapi.tcl
# OpenAPI tools.
##

namespace eval openapi {

  variable operations

  proc loadOperations { fname } {
    variable operations
    array set operations [_loadFile $fname]
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

  proc _loadFile {filename} {
    set content ""
    set fd -1
  
    catch { set fd [open $filename r] }
    if { 0 <= $fd } then {
      set content [read $fd]
      close $fd
    }
    return $content
  }

}