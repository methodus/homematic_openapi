#!/bin/tclsh

set hm_script {

  object oChannel = dom.GetObject(sChannelId);

  if (oChannel.TypeName() != "CHANNEL") {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No channel with ID '" # sChannelId # "' found}";
    quit;
  }
}

append hm_script [file::load "operations/channels/channelConsts.hms"]
append hm_script [file::load "operations/channels/channel.hms"]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sChannelId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}