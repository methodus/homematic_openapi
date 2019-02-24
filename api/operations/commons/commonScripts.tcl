#!/bin/tclsh

proc hmscript_deleteElement { list id } {

  set hm_script "var sElementId = \"$id\";\n"
  append hm_script "object oElements = dom.GetObject( $list );\n"
  append hm_script {
    if( oElements ) {
      object oElement = dom.GetObject( system.GetVar("sElementId") );
      if( oElement ) {
        if( oElements.Remove( oElement.ID() ) ) {
          if( !oElement.Unerasable() ) {
            if( !dom.DeleteObject( oElement.ID() ) ) {
              string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete element with ID '" # sElementId # "'}";
              quit;
            } else {
              Write("success");
            }
          } else {
            string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete element with ID '" # sElementId # "'}";
            quit;
          }
        } else {
          string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete element with ID '" # sElementId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 404 STATUS {Not found} MESSAGE {Cannot find element with ID '" # sElementId # "'}";
        quit;
      }
    } else {
      string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete element with ID '" # sElementId # "'}";
      quit;
    }
    return;
  }

  return $hm_script

}