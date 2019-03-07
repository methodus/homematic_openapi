#!/bin/tclsh

proc hmscript_sysvars { } {
  set template {
    string sSysVarId;

    WriteLine("{");
    WriteLine("\"systemVariables\" : " # '[');
    boolean bFirst=true;
    foreach (sSysVarId, dom.GetObject(ID_SYSTEM_VARIABLES).EnumUsedIDs()){
      object oSysVar = dom.GetObject(sSysVarId);

      if (oSysVar) {
        if (!bFirst) {
          WriteLine(",");
        } else {
          bFirst = false;
        }

        !< templateSysvar >!

      }
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
    object oSysVar = dom.GetObject(sSysVarId);

    if ((OT_ALARMDP != oSysVar.Type()) && (OT_VARDP != oSysVar.Type())) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No sysvar with ID '" # sSysVarId # "' found}";
      quit;
    }
  }

  append hm_script [hmscript_sysvar_]

  return $hm_script
}

proc hmscript_sysvar_ { } {
  set hm_script {

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
      WriteLine("\"valueList\" : " # '[');
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

    WriteLine("\"min\" : \"" # oSysVar.ValueMin() # "\",");
    WriteLine("\"max\" : \"" # oSysVar.ValueMax() # "\",");
    WriteLine("\"unit\" : \"" # oSysVar.ValueUnit() # "\",");
    WriteLine("\"type\" : \"" # oSysVar.ValueType() # "\",");
    WriteLine("\"subtype\" : \"" # oSysVar.ValueSubType() # "\",");
    WriteLine("\"timestamp\" : \"" # oSysVar.Timestamp().ToInteger() # "\"");
    WriteLine("}");
  }

  return $hm_script
}

proc hmscript_newSysvar { name type description unit varargs channelId } {
  set hm_script [hmscript_createSysvarProps $name $type $description $unit]
  append hm_script {
    integer ist = system.GetVar("iSubType");

    object oSysVars = dom.GetObject( ID_SYSTEM_VARIABLES );
    object oAlarms = dom.GetObject( ID_ALARMS );
    
    object oSysVar;
    if( ist == istAlarm )
    {
      oSysVar = dom.CreateObject(OT_ALARMDP);
      oSysVar.Name( system.GetVar("sName") );
      oSysVar.AlSetBinaryCondition();
      oSysVars.Add( oSysVar.ID() );
    }
    else
    {
      oSysVar = dom.CreateObject(OT_VARDP);
      oSysVar.Name( system.GetVar("sName") );
      oSysVars.Add( oSysVar.ID() );
    }
    
    oSysVar.DPInfo( system.GetVar("sInfo") );
    oSysVar.ValueUnit( system.GetVar("sUnit") );
  }
  append hm_script [hmscript_saveSysvarByArgs $type $varargs]
  append hm_script [hmscript_saveSysvarChannel $channelId]
  append hm_script "dom.RTUpdate(0);"
  append hm_script "var ID = oSysVar.ID();"

  return $hm_script
}

proc hmscript_editSysvar { id name type description unit varargs channelId } {
  set hm_script [hmscript_createSysvarProps $name $type $description $unit]
  append hm_script "var sSysVarId = \"$id\";\n"
  append hm_script {
    object oSysVar = dom.GetObject( system.GetVar("sSysVarId") );

    if ((OT_ALARMDP != oSysVar.Type()) && (OT_VARDP != oSysVar.Type())) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No system variable with ID '" # sSysVarId # "' found}";
      quit;
    }

    oSysVar.Name( system.GetVar("sName") );
    object ch = dom.GetObject( oSysVar.Channel() );
    if( ch ) {
      ch.DPs().Remove( oSysVar.ID() );
    }
    if( (ist == istAlarm) && (oSysVar.ValueSubType() != istAlarm) ) {
      dom.DeleteObject( oSysVar.ID() );
      oSysVar = dom.CreateObject( OT_ALARMDP, system.GetVar("sName") );
      oSysVars.Add( oSysVar.ID() );
    }
    if( (ist != istAlarm ) && (oSysVar.ValueSubType() == istAlarm) ) {
      dom.DeleteObject( oSysVar.ID() );
      oSysVar = dom.CreateObject( OT_VARDP, system.GetVar("sName") );
      oSysVars.Add( oSysVar.ID() );
    }

    oSysVar.DPInfo( system.GetVar("sInfo") );
    oSysVar.ValueUnit( system.GetVar("sUnit") );
  }
  append hm_script [hmscript_saveSysvarByArgs $type $varargs]
  append hm_script [hmscript_saveSysvarChannel $channelId]
  append hm_script "dom.RTUpdate(0);"

  return $hm_script
}

proc hmscript_createSysvarProps { name type description unit } {
  set hm_script "var sName = \"$name\";\n"
  append hm_script "var iSubType = $type;\n"
  append hm_script "var sInfo = \"$description\";\n"
  append hm_script "var sUnit = \"$unit\";\n"

  return $hm_script
}

proc hmscript_saveSysvarByArgs { type varargs } {
  array set sysvarArgs $varargs
  set hm_script {}
  switch $type {
    0 {
      set minValue 0
      set maxValue 65535
      if { [info exists sysvarArgs(minValue)] != 0 } then { set minValue $sysvarArgs(minValue) }
      if { [info exists sysvarArgs(maxValue)] != 0 } then { set maxValue $sysvarArgs(maxValue) }
      append hm_script [hmscript_saveSysvarGeneric $minValue $maxValue]
    }
    2 {
      set trueString 1
      set falseString 0
      if { [info exists sysvarArgs(trueString)] != 0 } then { set trueString $sysvarArgs(trueString) }
      if { [info exists sysvarArgs(falseString)] != 0 } then { set trueString $sysvarArgs(trueString) }
      append hm_script [hmscript_saveSysvarBoolean $trueString $falseString]
    }
    6 {
      set trueString 1
      set falseString 0
      if { [info exists sysvarArgs(trueString)] != 0 } then { set trueString $sysvarArgs(trueString) }
      if { [info exists sysvarArgs(falseString)] != 0 } then { set trueString $sysvarArgs(trueString) }
      append hm_script [hmscript_saveSysvarAlarm $trueString $falseString]
    }
    11 {
      append hm_script [hmscript_saveSysvarString]
    }
    29 {
      set valueList "A;B;C"
      if { [info exists sysvarArgs(valueList)] != 0 } then { set valueList $sysvarArgs(valueList) }
      append hm_script [hmscript_saveSysvarList $valueList]
    }
  }

  return $hm_script
}

proc hmscript_saveSysvarBoolean { true false } {
  set hm_script "var sTrue = \"$true\";\n"
  append hm_script "var sFalse = \"$false\";\n"
  append hm_script {
    oSysVar.ValueType( ivtBinary );
    oSysVar.ValueSubType( istBool );
    oSysVar.ValueName1(system.GetVar("sTrue"));
    oSysVar.ValueName0(system.GetVar("sFalse"));
    oSysVar.State(false);
  }

  return $hm_script
}

proc hmscript_saveSysvarAlarm { true false } {
  set hm_script "var sTrue = \"$true\";\n"
  append hm_script "var sFalse = \"$false\";\n"
  append hm_script {
    oSysVar.ValueType( ivtBinary );
    oSysVar.ValueSubType( istAlarm );
    oSysVar.ValueName1(system.GetVar("sTrue"));
    oSysVar.ValueName0(system.GetVar("sFalse"));
    oSysVar.AlType(atSystem);
    oSysVar.AlArm(true);
  }

  return $hm_script
}

proc hmscript_saveSysvarString { } {
  set hm_script {
    oSysVar.ValueType(ivtString);
    oSysVar.ValueSubType(istChar8859);
    oSysVar.State("???");
  }

  return $hm_script
}

proc hmscript_saveSysvarGeneric { min max } {
  set hm_script "var iMinVal = $min;\n"
  append hm_script "var iMaxVal = $max;\n"
  append hm_script {
    oSysVar.ValueType( ivtFloat );
    oSysVar.ValueSubType( istGeneric );
    oSysVar.ValueMin(system.GetVar("iMinVal"));
    oSysVar.ValueMax(system.GetVar("iMaxVal"));
    oSysVar.State(system.GetVar("iMinVal"));
  }

  return $hm_script
}

proc hmscript_saveSysvarList { valuelist } {
  set hm_script "var sValList = \"$valuelist\";\n"
  append hm_script {
    oSysVar.ValueType( ivtInteger );
    oSysVar.ValueSubType( istEnum );
    oSysVar.ValueList(system.GetVar("sValList"));
    oSysVar.State(0);
  }

  return $hm_script
}

proc hmscript_saveSysvarChannel { channelId } {
  set hm_script "var iChnId = \"$channelId\";\n"
  append hm_script {
    object oChn = dom.GetObject( system.GetVar("iChnId") );
    if (oChn) {
      oChn.DPs().Add( oSysVar.ID() );
      oSysVar.Channel( oChn.ID() );
    } else {
      oChn = dom.GetObject( oSysVar.Channel() );
      if( oChn ) {
        oChn.DPs().Remove( oSysVar.ID() );
      }
      oSysVar.Channel( ID_ERROR );
    }
  }

  return $hm_script
}

proc hmscript_deleteSysvar { id } {
  set hm_script {}
  append hm_script "var sSysVarId = \"$id\";\n"
  append hm_script {
    object oSysVars = dom.GetObject( ID_SYSTEM_VARIABLES )
    if ( oSysVars ) {
      object oSysVar = dom.GetObject(sSysVarId);

      if ( oSysVar ) {
        if (OT_ALARMDP != oSysVar.Type() && OT_VARDP != oSysVar.Type()) {
          string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No sysvar with ID '" # sSysVarId # "' found}";
          quit;
        }

        if ( oSysVars.Remove(oSysVar.ID()) ) {
          if( !oElement.Unerasable() ) {
            object ch = dom.GetObject( oSysVar.Channel() );
            if( ch ) {
              ch.DPs().Remove( oSysVar.ID() );
            }

            if( !dom.DeleteObject( oSysVar.ID() ) ) {
              string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete " # sType # " with ID '" # sElementId # "'}";
              quit;
            } else {
              Write("success");
            }
          } else {
            string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete sysvar with ID '" # sSysVarId # "'}";
            quit;
          }
        } else {
          string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete sysvar with ID '" # sSysVarId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No sysvar with ID '" # sSysVarId # "' found}";
        quit;
      }
    } else {
      string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete sysvar with ID '" # sSysVarId # "'}";
      quit;
    }
    
  }

  return $hm_script
}

proc hmscript_setSysvar { id value } {
  set hm_script {}
  append hm_script "var vValue = \"$value\";\n"
  append hm_script "var sSysVarId = \"$id\";\n"
  append hm_script {
    object oSysVar = dom.GetObject(sSysVarId);

    if ((OT_ALARMDP != oSysVar.Type()) && (OT_VARDP != oSysVar.Type())) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No sysvar with ID '" # sSysVarId # "' found}";
      quit;
    }

    if (!oSysVar.State( system.GetVar("vValue") )) {
      string ERROR = "CODE 400 STATUS {Bad request} MESSAGE {Setting sysvar with ID '" # sSysVarId # "' to value '" # vValue # "' failed}";
      quit;
    }
  }

  return $hm_script
}
