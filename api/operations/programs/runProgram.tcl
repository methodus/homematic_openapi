#!/bin/tclsh

set hm_script {
  object oProgram = dom.GetObject(sProgramId);

  if (!oProgram.IsOfType(OT_PROGRAM)) {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No program with ID '" # sProgramId # "' found}";
    quit;
  }

  oProgram.ProgramExecute();
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sProgramId) $id
  hmscript::run $hm_script args
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}