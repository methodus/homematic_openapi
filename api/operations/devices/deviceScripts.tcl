#!/bin/tclsh

source operations/channels/channelScripts.tcl

proc hmscript_device_ { flatten withState } {
  set template {
    boolean bDeviceReady = oDevice.ReadyConfig();
    if ((true == bDeviceReady) && ("HMW-RCV-50" != oDevice.HssType()) && ("HM-RCV-50" != oDevice.HssType())) {
      string sDeviceIfaceId = oDevice.Interface();
      string sDeviceIface   = dom.GetObject(sDeviceIfaceId).Name();
      string sDeviceType    = oDevice.HssType();

      if (!bFirstDevice) {
        WriteLine(",");
      } else {
        bFirstDevice = false;
      }

      WriteLine("{");
      WriteLine("\"name\" : \"" # oDevice.Name() # "\"," );
      WriteLine("\"address\" : \"" # oDevice.Address() # "\"," );
      WriteLine("\"id\" : \"" # oDevice.ID() # "\"," );
      WriteLine("\"interface\" : \"" # sDeviceIface # "\"," );
      WriteLine("\"type\" : \"" # sDeviceType # "\"," );
      WriteLine("\"configReady\" : " # bDeviceReady # ",");

      var aChannelIds = oDevice.Channels();
      !< templateChannels >!

      WriteLine("}");
    }
  }

  set vars(templateChannels) [hmscript_channels $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_device { id flatten withState } {
  set hm_script {}
  append hm_script "var sDeviceId = \"$id\";\n"
  append hm_script {
    object oDevice = dom.GetObject(sDeviceId);
    if (oDevice.TypeName() != "DEVICE") {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No device with ID '" # sDeviceId # "' found}";
      quit;
    }
    boolean bFirstDevice = true;
  }
  append hm_script [hmscript_device_ $flatten $withState]
}

proc hmscript_devices { flatten withState } {
  set template {
    WriteLine("{ \"devices\" : " # '[');

    string sDeviceId;
    boolean bFirstDevice = true;
    foreach (sDeviceId, root.Devices().EnumUsedIDs()) {
      object oDevice = dom.GetObject(sDeviceId);

      !< templateDevice >!
    }

    WriteLine("]");
    WriteLine("}");

  }

  set vars(templateDevice) [hmscript_device_ $flatten $withState]
  set hm_script [file::processTemplate $template vars]
}