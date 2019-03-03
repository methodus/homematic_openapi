#!/bin/tclsh

proc hmscript_sysvars { } {
  set template {
    string sSysVarId;

    WriteLine("{");
    WriteLine("\"systemVariables\" : " # '[');
    boolean bFirst=true;
    foreach (sSysVarId, dom.GetObject(ID_SYSTEM_VARIABLES).EnumUsedIDs()){
      oSysVar = dom.GetObject(sSysVarId);

      !< templateSysvar >!
    }

    WriteLine("]");
    WriteLine("}");
  }

  array set vars {}
  set vars(templateSysvar) [hmscript_sysvar_]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_sysvar { id } {
  set hm_script {}
  append hm_script "var sSysVarId = \"$id\";\n"
  append hm_script {
    oSysVar = dom.GetObject(sSysVarId);
  }

  append hm_script [hmscript_sysvar_]

  return $hm_script
}

proc hmscript_sysvar_ { } {
  set hmscript {
    
    if (oSysVar) {
      if (!bFirst) {
        WriteLine(",");
      } else {
        bFirst = false;
      }

      WriteLine("{");
      WriteLine("\"name\" : \"" # oSysVar.Name() # "\",");
      WriteLine("\"id\" : \"" # oSysVar.ID() # "\",");
      WriteLine("\"value\" : \"" # oSysVar.Value() # "\",");

      if (oSysVar.ValueType() == 2) {
        WriteLine("\"valueName0\" : \"" # oSysVar.ValueName0() # "\",");
        WriteLine("\"valueName1\" : \"" # oSysVar.ValueName1() # "\",");
      }

      if (oSysVar.ValueType() == 16) {
        string sValueText;
        boolean first = true;
        WriteLine("\"valueList\" : " # [);
        foreach (sValueText, oSysVar.ValueList().Split(';')) {
          if (first) {
            first = false;
          } else {
            Write(",");
          }
          WriteLine("\"" # sValueText # "\"");
        }
        WriteLine("],");
        WriteLine("\"valueText\" : \"" # oSysVar.ValueList().StrValueByIndex(';', oSysVar.Value()) # "\",");
      }

      Write("\"variable\" : \"");
      if (oSysVar.ValueSubType() == 6) {
        Write( oSysVar.AlType());
      } else {
        Write( oSysVar.Variable());
      }
      WriteLine("\",");

      WriteLine("\"min\" : \"" # oSysVar.Value() # "\",");
      WriteLine("\"max\" : \"" # oSysVar.Value() # "\",");
      WriteLine("\"unit\" : \"" # oSysVar.Value() # "\",");
      WriteLine("\"type\" : \"" # oSysVar.Value() # "\",");
      WriteLine("\"subtype\" : \"" # oSysVar.Value() # "\",");
      WriteLine("\"timestamp\" : \"" # oSysVar.Value() # "\"");
      WriteLine("}");					   
  
    }
  }

  return $hm_script
}

proc hmscript_newSysvar { } {

}

proc hmscript_deleteSysvar { id } {

}

proc hmscript_setSysvar { id value } {

}