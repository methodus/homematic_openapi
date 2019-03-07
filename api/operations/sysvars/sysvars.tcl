#!/bin/tclsh

source operations/sysvars/sysvarScripts.tcl

set hm_script [hmscript_sysvars]

httptool::response::send [hmscript::run $hm_script]