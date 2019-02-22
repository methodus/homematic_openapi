#!/bin/tclsh

set hm_script {
  object oFunction = dom.GetObject(sFunctionId);
  if (oFunction && oFunction.TypeName() == "ENUM") {
    if ( system.IsVar("sFunctionName") ) {
      oFunction.Name( system.GetVar("sFunctionName") );
    }
    if ( system.IsVar("sFunctionDesc") ) {
      oFunction.EnumInfo( system.GetVar("sFunctionDesc") )
    }
    Write("success");
  } else {
    string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No function with ID '" # sFunctionId # "' found}";
    quit;
  }
  return;
}

if {0 != [regexp $operation(REGEXP) $resource path id]} {
  set args(sFunctionId) $id

  if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
  } else {
    set args(sFunctionName) $postData(name)
    set args(sFunctionDesc) $postData(description)

    hmscript::run $hm_script args
    lappend header "Location" [httptool::request::resolvePath "$resource"]

    httptool::response::sendWithStatusAndHeaders 204 "No Content" $header
  }
} else {
  error [openapi::createError 400 "Bad request" "Invalid resource request: $resource"]
}