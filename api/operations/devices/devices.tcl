#!/bin/tclsh

source operations/devices/deviceScripts.tcl

set hm_script [hmscript_devices $flatten $withState]

httptool::response::send [hmscript::run $hm_script]
