#!/bin/tclsh

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

set vars(templateDevice) [file::load "operations/devices/device.hms"]
set hm_script [file::processTemplate $template vars]

set output [hmscript::run $hm_script]
httptool::response::send $output
