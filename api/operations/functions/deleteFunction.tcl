#!/bin/tclsh

set hm_script {
  object oFunctions = dom.GetObject( ID_ROOMS );
  if( oFunctions ) {
    object oFunction = dom.GetObject( system.GetVar("sFunctionId") );
    if( oFunction ) {
      if( oFunctions.Remove( oFunction.ID() ) ) {
        if( !oFunction.Unerasable() ) {
          if( !dom.DeleteObject( oFunction.ID() ) ) {
            string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete function '" # sFunctionId # "'}";
            quit;
          } else {
            Write("success");
          }
        } else {
          string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete function '" # sFunctionId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete function '" # sFunctionId # "'}";
        quit;
      }
    } else {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {Cannot find function '" # sFunctionId # "'}";
      quit;
    }
  } else {
    string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete function '" # sFunctionId # "'}";
    quit;
  }
  return;
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sFunctionId) $id
  array set output [hmscript::runWithResult $hm_script args]
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}