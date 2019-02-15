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

  proc matchResourcePath { path } {
    variable operations
    foreach name [array names operations] {
      if { 0 != [_matchPath $path $name] } {
        return $operations($name)
      }
    }

    return -code error "Operation for $path not found"
  }

  proc _matchPath { path pattern } {
    if { "*" != [string index $pattern end] } {
      append pattern *
    }
    return [string match $pattern $path]
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