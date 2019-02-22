#!/bin/tclsh

set template {
  if( system.IsVar( "sFunctionName" ) ) {
    object oFunction = dom.CreateObject( OT_ENUM, system.GetVar( "sFunctionName" ) );
    if( oFunction ) {
      oFunction.EnumType( etFunction );
      boolean res = dom.GetObject( ID_ROOMS ).Add( oFunction );
      if( !res ) {
        dom.DeleteObject( oFunction.ID() );
        string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot add function '" # sFunctionName # "'}";
        quit;
      }
      else {
        var ID = oFunction.ID();
        !< templateFunction >!
      }
    }
    else {
      string ERROR = "CODE 400 STATUS {Bad request} MESSAGE {Function with name '" # sFunctionName # "' already exists}";
      quit;
    }
  }
}

set vars(templateFunction) [file::load "operations/functions/function.hms"]
set hm_script [file::processTemplate $template vars]

if { [catch { array set postData [httptool::request::parsePost] } error ] } {
  error [openapi::createError 400 "Bad request" "Invalid data: $error"]
} else {
  if { [info exists postData(name)] == 0 } {
    error [openapi::createError 400 "Bad request" "Function name not specified"]
  }

  set args(sFunctionName) $postData(name)
  array set output [hmscript::runWithResult $hm_script args]
  lappend header "Location" [httptool::request::resolvePath "$resource/$output(ID)"]

  httptool::response::sendWithStatusAndHeaders 201 "Created" $header $output(STDOUT)
}

