#!/bin/tclsh

set hm_script ""
append hm_script {
  object oRoom;
  string sRoomId;
  string sRoomName;
  string sChannelId;

  WriteLine("{ \"rooms\" : " # '[');

  boolean bFirstRoom = true;
  foreach (sRoomId, dom.GetObject(ID_ROOMS).EnumUsedIDs()) {
    oRoom = dom.GetObject(sRoomId);

    if (!bFirstRoom) {
      WriteLine(",");
    } else {
      bFirstRoom = false;
    }

    WriteLine("{");
    WriteLine("\"name\" : \"" # oRoom.Name() # "\"," );
    WriteLine("\"id\" : \"" # sRoomId # "\"," );

    WriteLine("\"channels\" : " # '[');

    boolean bFirstChannel = true;
    foreach (sChannelId, oRoom.EnumUsedIDs()) {
      object room = dom.GetObject(sChannelId);

      if (!bFirstChannel) {
        WriteLine(",");
      } else {
        bFirstChannel = false;
      }

      WriteLine("{");
      WriteLine("\"name\" : \"" # room.Name() # "\"," );
      WriteLine("\"id\" : \"" # sChannelId # "\"" );
      WriteLine("}");
    }

    WriteLine("]");
    WriteLine("}");
  }

  WriteLine("]");
  WriteLine("}");
}

httptool::response::send [hmscript::run $hm_script]