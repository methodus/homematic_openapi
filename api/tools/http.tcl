#!/bin/tclsh
##
# http.tcl
# HTTP tools.
##

namespace eval httptool {

  namespace eval request {

    proc _parseUrlEncodedParameters { input } {
      set list ""
      catch {
        set pairs [split $input &]
        foreach pair $pairs {
          if {0 != [regexp "^(\[^=]*)=(.*)$" $pair dummy varname val]} {
            lappend list $varname $val
          }
        }
      }
      return $list
    }

    ##
    # Parse GET query parameters
    ##
    proc parseQuery {  } {
      return [_parseUrlEncodedParameters $::env(QUERY_STRING)]
    }

    proc parsePost { } {
      set list {}
      catch {
        set list [_parseUrlEncodedParameters [read stdin $::env(CONTENT_LENGTH)]]
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

    proc resolvePath { resourcePath } {
      return "[file dirname $::env(SCRIPT_NAME)]$resourcePath"
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
    proc sendWithStatus {code status { arg - }} {
      set headers {}
      sendWithStatusAndHeaders $code $status $headers $arg
    }

    proc sendWithStatusAndHeaders {code status p_headers { arg - }} {
      array set headers $p_headers

      puts "Status: $code $status"
      foreach name [array names headers] {
        puts "$name: $headers($name)"
      }

      if { $arg != "-" } {
        puts "Content-Type: application/json;Charset=UTF-8"
        set output [encoding convertfrom utf-8 $arg]
        puts ""
        puts $output
      } else {
        puts ""
      }
    }

  }

}