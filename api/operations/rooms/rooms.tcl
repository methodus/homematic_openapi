#!/bin/tclsh

set templateRooms {
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

set vars(templateRoom) [file::load "operations/rooms/room.hms"]
set hm_script [file::processTemplate $templateRooms vars]

httptool::response::send [hmscript::run $hm_script]