#!/bin/tclsh

set template {
  string sProgramId;
  object oProgram;

  WriteLine("{");
  WriteLine("\"programs\" : " # '[');

  boolean bFirst=true;
  foreach (sProgramId, dom.GetObject(ID_PROGRAMS).EnumUsedIDs()) {
    oProgram = dom.GetObject(sProgramId);

    if (!bFirst) {
      WriteLine(",");
    } else {
      bFirst = false;
    }

    !< templateProgram >!

  }

  WriteLine("]");
  WriteLine("}");
}

array set vars {}
set vars(templateProgram) [file::load "operations/programs/program.hms"]
set hm_script [file::processTemplate $template vars]

httptool::response::send [hmscript::run $hm_script]