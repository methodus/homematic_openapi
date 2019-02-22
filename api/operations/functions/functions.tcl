#!/bin/tclsh

set templateFunctions {
  object oFunction;
  string sFunctionId;
  string sFunctionName;
  WriteLine("{ \"functions\" : " # '[');
  boolean bFirstFunction = true;
  foreach (sFunctionId, dom.GetObject(ID_FUNCTIONS).EnumUsedIDs()) {
    oFunction = dom.GetObject(sFunctionId);
    if (!bFirstFunction) {
      WriteLine(",");
    } else {
      bFirstFunction = false;
    }
    !< templateFunction >!
  }
  WriteLine("]");
  WriteLine("}");
}

set vars(templateFunction) [file::load "operations/functions/function.hms"]
set hm_script [file::processTemplate $templateFunctions vars]

httptool::response::send [hmscript::run $hm_script]