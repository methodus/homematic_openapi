#!/bin/tclsh

proc get_rooms {} {
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

  return [hmscript::run $hm_script]
}

set output ""

catch {
  set method [httptool::request::method]
  switch $method {
    GET {
      array set params [httptool::request::parseQuery]
      if { [info exists params(id)] } {
        #set output [get_device $params(id)]
        set output [get_rooms]
      } else {
        set output [get_rooms]
      }
    }
  }
} err

httptool::response::send $output