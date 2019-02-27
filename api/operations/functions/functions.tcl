#!/bin/tclsh

source operations/functions/functionScripts.tcl

set hm_script [hmscript_functions $flatten $withState]

httptool::response::send [hmscript::run $hm_script]