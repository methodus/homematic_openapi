#!/bin/tclsh

set hm_script {

  object oDevice = dom.GetObject(sDeviceId);

  if (oDevice.TypeName() != "DEVICE") {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No device with ID '" # sDeviceId # "' found}";
    quit;
  }

  boolean bFirstDevice = true;
}

append hm_script [file::load "operations/devices/device.hms"]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sDeviceId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}