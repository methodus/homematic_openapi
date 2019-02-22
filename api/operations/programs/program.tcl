#!/bin/tclsh

set hm_script {
  object oProgram = dom.GetObject(sProgramId);

  if (oProgram.Type() != OT_PROGRAM) {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No program with ID '" # sProgramId # "' found}";
    quit;
  }
}

append hm_script [file::load "operations/programs/program.hms"]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sProgramId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}