#!/bin/tclsh

source operations/functions/functionScripts.tcl

if { [catch { array set postData [httptool::request::parsePost] } error ] } {
  error [openapi::createError 400 "Bad request" "Invalid data: $error"]
} else {
  if { [info exists postData(name)] == 0 } {
    error [openapi::createError 400 "Bad request" "Function name not specified"]
  }

  set hm_script [hmscript_newFunction $postData(name)]
  array set output [hmscript::runWithResult $hm_script]
  lappend header "Location" [httptool::request::resolvePath "$resource/$output(ID)"]

  httptool::response::sendWithStatusAndHeaders 201 "Created" $header $output(STDOUT)
}

