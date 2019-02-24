
source operations/channels/channelScripts.tcl
source operations/commons/commonScripts.tcl

proc hmscript_deleteRoom { id } {
  return [hmscript_deleteElement ID_ROOMS $id ]
}

proc hmscript_newRoom { } {

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

  set vars(templateRoom) [hmscript_room_ 0 0]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_rooms { flatten withState } {

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

  set vars(templateRoom) [hmscript_room_ $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_room { flatten withState } {

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

  append hm_script [hmscript_room_ $flatten $withState]

  return $hm_script

}

proc hmscript_room_ { flatten withState } {

  set template {

    WriteLine("{");
    WriteLine("\"name\" : \"" # oRoom.Name() # "\"," );
    WriteLine("\"description\" : \"" # oRoom.EnumInfo() # "\"," );
    WriteLine("\"id\" : \"" # oRoom.ID() # "\"," );
    WriteLine("\"type\" : \"" # oRoom.EnumType() # "\"," );

    var aChannelIds = oRoom.EnumUsedIDs();
    !< templateChannels >!

    WriteLine("}");

  }

  set vars(templateChannels) [hmscript_channels $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script

}