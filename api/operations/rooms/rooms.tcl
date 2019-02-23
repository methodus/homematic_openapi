#!/bin/tclsh

source operations/channels/channelScripts.tcl

set template {
  object oRoom;
  string sRoomId;
  string sRoomName;
  WriteLine("{ \"rooms\" : " # '[');
  boolean bFirstRoom = true;
  foreach (sRoomId, dom.GetObject(ID_ROOMS).EnumUsedIDs()) {
    oRoom = dom.GetObject(sRoomId);
    if (!bFirstRoom) {
      WriteLine(",");
    } else {
      bFirstRoom = false;
    }
    !< templateRoom >!
  }
  WriteLine("]");
  WriteLine("}");
}

set vars1(templateChannels) [hmscript_channels]
set vars2(templateRoom) [file::processTemplate [file::load "operations/rooms/room.hms"] vars1]
set hm_script [file::processTemplate $template vars2]

httptool::response::send [hmscript::run $hm_script]