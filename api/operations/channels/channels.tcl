#!/bin/tclsh

source operations/channels/channelScripts.tcl

set hm_script {
  var aChannelIds = root.Channels().EnumUsedIDs();
}

append hm_script WriteLine("{");
append hm_script [hmscript_channels]
append hm_script WriteLine("}");

set output [hmscript::run $hm_script]
httptool::response::send $output
