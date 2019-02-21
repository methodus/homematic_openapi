#!/bin/tclsh

set hm_script {
  object oRooms = dom.GetObject( ID_ROOMS );
  if( oRooms ) {
    object oRoom = dom.GetObject( system.GetVar("sRoomId") );
    if( oRoom ) {
      if( oRooms.Remove( oRoom.ID() ) ) {
        if( !oRoom.Unerasable() ) {
          if( !dom.DeleteObject( oRoom.ID() ) ) {
            string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete room '" # sRoomId # "'}";
            quit;
          } else {
            Write("success");
          }
        } else {
          string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete room '" # sRoomId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete room '" # sRoomId # "'}";
        quit;
      }
    } else {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {Cannot find room '" # sRoomId # "'}";
      quit;
    }
  } else {
    string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete room '" # sRoomId # "'}";
    quit;
  }
  return;
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sRoomId) $id
  array set output [hmscript::runWithResult $hm_script args]
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}