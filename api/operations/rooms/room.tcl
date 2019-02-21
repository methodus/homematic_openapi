#!/bin/tclsh

set hm_script {
  object oRoom;
  string sRoomName;
  string sChannelId;

  oRoom = dom.GetObject(sRoomId);

  if (oRoom.EnumType() != etRoom) {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No room with ID '" # sRoomId # "' found}";
    quit;
  }
}

append hm_script [file::load "operations/rooms/room.hms"]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sRoomId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}