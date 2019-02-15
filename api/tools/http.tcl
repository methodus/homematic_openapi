#!/bin/tclsh
##
# http.tcl
# HTTP tools.
##

namespace eval httptool {

  namespace eval request {

    ##
    # Parse GET query parameters
    ##
    proc parseQuery {  } {
        set list ""
        catch {
            set input $::env(QUERY_STRING)
            set pairs [split $input &]
            foreach pair $pairs {
                if {0 != [regexp "^(\[^=]*)=(.*)$" $pair dummy varname val]} {
                    lappend list $varname $val
                }
            }
        }
        return $list
    }

    proc method {} {
      return $::env(REQUEST_METHOD)
    }

    proc resourcePath { {appendSlash 0} } {
      set basename [file dirname $::env(SCRIPT_NAME)]
      set resource [string replace $::env(REQUEST_URI) 0 [expr {[string length $basename]-1}]]

      if { 0 != $appendSlash } {
        if { "/" != [string index $resource end] } {
          append resource /
        }
      }

      return $resource
    }

  }

  namespace eval response {

    ##
    # Sendet eine JSON Antwort mit 200 OK
    ##
    proc send { p_text } {
        sendWithStatus 200 ok $p_text
    }

    ##
    # Sendet eine JSON Antwort unter Angabe von HTTP-Statuscode und Statusmeldung
    ##
    proc sendWithStatus {code status arg} {
      set output [encoding convertfrom utf-8 $arg]

      puts "Status: $code $status"
      puts "Content-Type: application/json;Charset=UTF-8"
      puts ""
      puts $output
    }

  }

}