#!/bin/tclsh

source operations/sysvars/sysvarScripts.tcl

if {0 != [regexp $operation(REGEXP) $resource path id]} {

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {

    if { [info exists postData(name)] == 0 } {
      error [openapi::createError 400 "Bad request" "Name not specified"]
    } else {
      set name $postData(name)
    }

    if { [info exists postData(type)] == 0 } {
      error [openapi::createError 400 "Bad request" "Type not specified"]
    } else {
      set type $postData(type)
    }

    set description ""
    if { [info exists postData(description)] != 0 } {
      set description $postData(description)
    }

    set unit ""
    if { [info exists postData(unit)] != 0 } {
      set unit $postData(unit)
    }

    set channelId 0
    if { [info exists postData(channelId)] != 0 } {
      set channelId $postData(channelId)
    }

    set hm_script [hmscript_editSysvar $id $name $type $description $unit [array get postData] $channelId]

    hmscript::runWithResult $hm_script
    lappend header "Location" [httptool::request::resolvePath "$resource"]

    httptool::response::sendWithStatusAndHeaders 204 "No Content" $header
  }

} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}
