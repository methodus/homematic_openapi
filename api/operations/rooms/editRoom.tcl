#!/bin/tclsh

set hm_script {
  object oRoom = dom.GetObject(sRoomId);
  if (oRoom && oRoom.TypeName() == "ENUM") {
    if ( system.IsVar("sRoomName") ) {
      oRoom.Name( system.GetVar("sRoomName") );
    }
    if ( system.IsVar("sRoomDesc") ) {
      oRoom.EnumInfo( system.GetVar("sRoomDesc") )
    }
    Write("success");
  } else {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No room with ID '" # sRoomId # "' found}";
    quit;
  }
  return;
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sRoomId) $id

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {
    set args(sRoomName) $postData(name)
    set args(sRoomDesc) $postData(description)

    hmscript::run $hm_script args
    lappend header "Location" [httptool::request::resolvePath "$resource"]

    httptool::response::sendWithStatusAndHeaders 204 "No Content" $header
  }
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}