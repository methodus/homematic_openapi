#!/bin/tclsh

set hm_script {
  object oPrograms = dom.GetObject( ID_PROGRAMS );
  if( oPrograms ) {
    object oProgram = dom.GetObject( system.GetVar("sProgramId") );
    if( oProgram ) {
      if( oPrograms.Remove( oProgram.ID() ) ) {
        if( !oProgram.Unerasable() ) {
          if( !dom.DeleteObject( oProgram.ID() ) ) {
            string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete program '" # sProgramId # "'}";
            quit;
          } else {
            Write("success");
          }
        } else {
          string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete program '" # sProgramId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete program '" # sProgramId # "'}";
        quit;
      }
    } else {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {Cannot find program '" # sProgramId # "'}";
      quit;
    }
  } else {
    string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete program '" # sProgramId # "'}";
    quit;
  }
  return;
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sProgramId) $id
  hmscript::runWithResult $hm_script args
  httptool::response::sendWithStatus 204 "No Content"
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}