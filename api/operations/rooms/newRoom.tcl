#!/bin/tclsh

set template {
  if( system.IsVar( "sRoomName" ) ) {
    object oRoom = dom.CreateObject( OT_ENUM, system.GetVar( "sRoomName" ) );
    if( oRoom ) {
      oRoom.EnumType( etRoom );
      boolean res = dom.GetObject( ID_ROOMS ).Add( oRoom );
      if( !res ) {
        dom.DeleteObject( oRoom.ID() );
        string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot add room '" # sRoomName # "'}";
        quit;
      }
      else {
        var ID = oRoom.ID();
        !< templateRoom >!
      }
    }
    else {
      string ERROR = "CODE 400 STATUS {Bad request} MESSAGE {Room with name '" # sRoomName # "' already exists}";
      quit;
    }
  }
}

set vars1(templateChannels) [hmscript_channels]
set vars2(templateRoom) [file::processTemplate [file::load "operations/rooms/room.hms"] vars1]
set hm_script [file::processTemplate $template vars2]

if { [catch { array set postData [httptool::request::parsePost] } error ] } {
  error [openapi::createError 400 "Bad request" "Invalid data: $error"]
} else {
  if { [info exists postData(name)] == 0 } {
    error [openapi::createError 400 "Bad request" "Room name not specified"]
  }

  set args(sRoomName) $postData(name)
  array set output [hmscript::runWithResult $hm_script args]
  lappend header "Location" [httptool::request::resolvePath "$resource/$output(ID)"]

  httptool::response::sendWithStatusAndHeaders 201 "Created" $header $output(STDOUT)
}

