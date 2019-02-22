#!/bin/tclsh

set hm_script {
  object oFunction;
  string sFunctionName;
  string sChannelId;

  oFunction = dom.GetObject(sFunctionId);

  if (oFunction.EnumType() != etFunction) {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No function with ID '" # sFunctionId # "' found}";
    quit;
  }
}

append hm_script [file::load "operations/functions/function.hms"]

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sFunctionId) $id
  set output [hmscript::run $hm_script args]
  httptool::response::send $output
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}