#!/bin/tclsh

source operations/sysvars/sysvarScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {
    set hm_script [hmscript_setSysvar $id $postData(value)]

    hmscript::run $hm_script
    lappend header "Location" [httptool::request::resolvePath "$resource"]

    #httptool::response::sendWithStatus 204 "No Content"
    httptool::response::sendWithStatusAndHeaders 204 "No Content" $header
  }
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}