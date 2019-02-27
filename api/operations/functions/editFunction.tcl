#!/bin/tclsh

source operations/functions/functionScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {
    hmscript::run [hmscript_editFunction $id $postData(name) $postData(description)]
    lappend header "Location" [httptool::request::resolvePath "$resource"]

    httptool::response::sendWithStatusAndHeaders 204 "No Content" $header
  }
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}