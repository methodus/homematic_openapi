#!/bin/tclsh

source operations/rooms/roomScripts.tcl

set hm_script [hmscript_rooms $flatten $withState]

httptool::response::send [hmscript::run $hm_script]