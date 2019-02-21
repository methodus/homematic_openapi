#!/bin/tclsh
##
# file.tcl
# File tools.
##

namespace eval file {

  proc load {filename} {
    set content ""
    set fd -1
  
    catch { set fd [open $filename r] }
    if { 0 <= $fd } then {
      set content [read $fd]
      close $fd
    }
    return $content
  }

  proc processTemplate { template p_args } {
    upvar $p_args args
    set variables {}

    foreach variable [array names args] {
      lappend variables "!< $variable >!" $args($variable)
    }
    
    set result [string map $variables $template]

    return $result
  }

}