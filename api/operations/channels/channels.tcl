#!/bin/tclsh

set template {

  string sChannelId;
  string sDPID;

  !< templateConsts >!

  WriteLine("{ \"channels\" : " # '[');

  boolean bFirstChannel = true;
  foreach (sChannelId, root.Channels().EnumUsedIDs()) {
    object oChannel = dom.GetObject(sChannelId);

    if (!bFirstChannel) {
      WriteLine(",");
    } else {
      bFirstChannel = false;
    }

    !< templateChannel >!
  }

  WriteLine("]");
  WriteLine("}");

}

set vars(templateConsts) [file::load "operations/channels/channelConsts.hms"]
set vars(templateChannel) [file::load "operations/channels/channel.hms"]
set hm_script [file::processTemplate $template vars]

set output [hmscript::run $hm_script]
httptool::response::send $output
