#!/bin/tclsh

source operations/datapoints/datapointScripts.tcl

proc hmscript_channelConts {} {
  set hm_script {
    string INVALID_ID = "65535";
    integer DIR_SENDER      = 1;
    integer DIR_RECEIVER    = 2;
  }

  return $hm_script
}

proc hmscript_channel_ { flatten withState } {
  set template [hmscript::createFlag "flatten" $flatten]

  append template {
    WriteLine("{");
    WriteLine("\"name\" : \"" # oChannel.Name() # "\"," );
    WriteLine("\"id\" : \"" # oChannel.ID() # "\"," );
    WriteLine("\"deviceId\" : \"" # oChannel.Device() # "\"," );

    string sDeviceIfaceId = oChannel.Interface();
    string sDeviceIface = "";
    if (sDeviceIfaceId != INVALID_ID) {
      sDeviceIface = dom.GetObject(sDeviceIfaceId).Name();
    }
    WriteLine("\"interface\" : \"" # sDeviceIface # "\"," );

    integer iChnDir     = oChannel.ChnDirection();
    string  sChnDir     = "UNKNOWN";
    if (DIR_SENDER   == iChnDir) { sChnDir = "SENDER";   }
    if (DIR_RECEIVER == iChnDir) { sChnDir = "RECEIVER"; }
    WriteLine("\"direction\" : \"" # sChnDir # "\"," );
    Write("\"address\" : \"" # oChannel.Address() # "\"" );

    if (flatten) {
      WriteLine(",")
      var aDPIds = oChannel.DPs().EnumUsedIDs();
      !< templateDPs >!
    }

    WriteLine("}");
  }

  set vars(templateDPs) [hmscript_datapoints $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_channel { { flatten 0 } { withState 0 } } {

  set hm_script {
    object oChannel = dom.GetObject(sChannelId);
    if (oChannel.TypeName() != "CHANNEL") {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No channel with ID '" # sChannelId # "' found}";
      quit;
    }
  }

  append hm_script [hmscript_channelConts]
  append hm_script [hmscript_channel_ $flatten $withState]

  return $hm_script

}

proc hmscript_channels { { flatten 0 } { withState 0 } } {

  set template {

    string sChannelId;
    string sDPID;
    object oChannel;

    !< templateConsts >!

    WriteLine("\"channels\" : " # '[');

    boolean bFirstChannel = true;
    foreach (sChannelId, aChannelIds) {
      oChannel = dom.GetObject(sChannelId);

      if (!bFirstChannel) {
        WriteLine(",");
      } else {
        bFirstChannel = false;
      }

      !< templateChannel >!
    }

    WriteLine("]");

  }

  set vars(templateConsts) [hmscript_channelConts]
  set vars(templateChannel) [hmscript_channel_ $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}