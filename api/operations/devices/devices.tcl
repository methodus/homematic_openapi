#!/bin/tclsh

proc get_devices {} {
  set hm_script ""
  append hm_script {

    integer DIR_SENDER      = 1;
    integer DIR_RECEIVER    = 1;
    string PARTNER_INVALID  = "65535";

    string sDeviceId;
    string sChnannelId;
    string sDPID;

    WriteLine("{ \"devices\" : " # '[');

    boolean bFirstDevice = true;
    foreach (sDeviceId, root.Devices().EnumUsedIDs()) {
      object oDevice = dom.GetObject(sDeviceId);
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
        WriteLine("\"id\" : \"" # sDeviceId # "\"," );
        WriteLine("\"interface\" : \"" # sDeviceIface # "\"," );
        WriteLine("\"type\" : \"" # sDeviceType # "\"" );
        WriteLine("}");
      }
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
        set output [get_devices]
      } else {
        set output [get_devices]
      }
    }
  }
} err

httptool::response::send $output