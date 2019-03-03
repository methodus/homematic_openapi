#!/bin/tclsh

source operations/datapoints/datapointScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {
    set hm_script [hmscript_setDatapoint $id $postData(value)] 
    httptool::response::send [hmscript::run $hm_script]
  }
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}