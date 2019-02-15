#!/bin/tclsh

################
# Load modules #
################
source /www/once.tcl
sourceOnce tools/json.tcl
sourceOnce tools/http.tcl
catch {
  sourceOnce tools/openapi.tcl
  sourceOnce tools/hmscript.tcl

  set resource [httptool::request::resourcePath]
  set method   [httptool::request::method]

  openapi::loadOperations operations.conf

  array set operation [openapi::matchResourcePath $resource]
  source [file join "operations/" $operation($method)]
} err

puts $err

#httptool::response::send [JSON::Parser::toJSON $json]