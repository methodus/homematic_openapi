
source operations/commons/commonScripts.tcl

proc hmscript_deleteProgram { id } {
  return [hmscript_deleteElement program ID_PROGRAMS $id ]
}

proc hmscript_runProgram { } {
  set hm_script {
    object oProgram = dom.GetObject(sProgramId);

    if (!oProgram.IsOfType(OT_PROGRAM)) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No program with ID '" # sProgramId # "' found}";
      quit;
    }

    oProgram.ProgramExecute();
  }

  return $hm_script
}

proc hmscript_program_ { } {

  set hm_script {
    WriteLine("{");
    WriteLine("\"name\" : \"" # oProgram.Name() # "\",");
    WriteLine("\"id\" : \"" # oProgram.ID() # "\",");
    WriteLine("\"description\" : \"" # oProgram.PrgInfo() # "\",");
    WriteLine("\"timestampLastExecuted\" : " # oProgram.ProgramLastExecuteTime().ToInteger() # ",");
    WriteLine("\"isActive\" : " # oProgram.Active() # ",");
    WriteLine("\"isVisible\" : " # oProgram.Visible() # ",");

    boolean canOperate = oProgram.UserAccessRights(iulOtherThanAdmin) == iarFullAccess;
    WriteLine("\"canOperate\" : " # canOperate);
    WriteLine("}");
  }

  return $hm_script
}

proc hmscript_program { } {
  set hm_script {
    object oProgram = dom.GetObject(sProgramId);

    if (oProgram.Type() != OT_PROGRAM) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No program with ID '" # sProgramId # "' found}";
      quit;
    }
  }

  append hm_script [hmscript_program_]

  return $hm_script
}

proc hmscript_programs { } {
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
  set vars(templateProgram) [hmscript_program_]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}