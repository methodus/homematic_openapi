#!/bin/tclsh

set hm_script {

  object oDevice = dom.GetObject(sDeviceId);

  if (oDevice.TypeName() != "DEVICE") {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No device with ID '" # sDeviceId # "' found}";
    quit;
  }

  boolean bDeviceReady = oDevice.ReadyConfig();

  if ((true == bDeviceReady) && ("HMW-RCV-50" != oDevice.HssType()) && ("HM-RCV-50" != oDevice.HssType())) {
    string sDeviceIfaceId = oDevice.Interface();
    string sDeviceIface   = dom.GetObject(sDeviceIfaceId).Name();
    string sDeviceType    = oDevice.HssType();

    WriteLine("{");
    WriteLine("\"name\" : \"" # oDevice.Name() # "\"," );
    WriteLine("\"address\" : \"" # oDevice.Address() # "\"," );
    WriteLine("\"id\" : \"" # sDeviceId # "\"," );
    WriteLine("\"interface\" : \"" # sDeviceIface # "\"," );
    WriteLine("\"type\" : \"" # sDeviceType # "\"" );
    WriteLine("}");
  }

}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sDeviceId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}